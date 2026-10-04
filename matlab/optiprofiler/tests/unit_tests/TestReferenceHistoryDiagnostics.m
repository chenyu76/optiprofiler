classdef TestReferenceHistoryDiagnostics < matlab.unittest.TestCase
    methods (Test)
        function historyFailureWarnsOncePerTrial(testCase)
            state = warning;
            cleanup = onCleanup(@() warning(state)); %#ok<NASGU>
            id = 'OptiProfiler:FeaturedProblem:ReferenceHistoryUnavailable';
            warning('on', id);
            for name = {'plain', 'truncated+truncated'}
                p = Problem(struct('fun', @(x) sum(x), 'x0', [0;0], ...
                    'cub', @TestReferenceHistoryDiagnostics.malformed));
                fp = FeaturedProblem(p, Feature(name{1}), 3, 17);
                testCase.verifyWarning(@() fp.fun([1;1]), id);
                lastwarn('');
                testCase.verifyEqual(fp.fun([1;1]), 2);
                testCase.verifyEqual(fp.fun([1;1]), 2);
                testCase.verifyTrue(all(isnan(fp.maxcv_hist)));
                [message, ~] = lastwarn;
                testCase.verifyEmpty(message);
                failure = fp.historyFailure();
                testCase.verifyEqual(failure.identifier, 'MATLAB:Problem:cubx_m_nonlinear_ub_NotConsistent');
                testCase.verifyNotEmpty(failure.message);
            end
        end
        function publicBenchmarkReportsSuppressedFailure(testCase)
            p = Problem(struct('fun', @(x) sum(x), 'x0', [0;0], ...
                'cub', @TestReferenceHistoryDiagnostics.malformed));
            options = struct('problem',p,'score_only',true,'silent',false, ...
                'solver_verbose',0,'n_jobs',1,'n_runs',1,'run_plain',false, ...
                'max_tol_order',1,'max_eval_factor',2,'project_x0',false);
            text = evalc('benchmark({@TestReferenceHistoryDiagnostics.probeSolver, @TestReferenceHistoryDiagnostics.probeSolver}, options);');
            testCase.verifySubstring(text,'Reference history unavailable');
            testCase.verifySubstring(text,'cubx_m_nonlinear_ub_NotConsistent');
        end
        function disabledWarningsKeepFailureStatus(testCase)
            state = warning;
            cleanup = onCleanup(@() warning(state)); %#ok<NASGU>
            warning('off', 'all');
            p = Problem(struct('fun', @(x) sum(x), 'x0', [0;0], ...
                'cub', @TestReferenceHistoryDiagnostics.malformed));
            fp = FeaturedProblem(p, Feature('plain'), 3, 17);
            testCase.verifyEqual(fp.fun([1;1]), 2);
            testCase.verifyNotEmpty(fp.historyFailure());
            testCase.verifyTrue(isnan(fp.maxcv_hist(end)));
        end
    end
    methods (Static)
        function x = probeSolver(fun,x0,varargin)
            fun([1;1]); x=x0;
        end
        function c = malformed(x)
            if all(x == 0), c = 1; else, c = [1;2]; end
        end
    end
end
