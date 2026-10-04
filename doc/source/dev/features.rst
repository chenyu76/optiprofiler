.. py:module:: optiprofiler

Problem features
================

.. currentmodule:: optiprofiler

.. autosummary::
    :toctree: generated/

    Feature

Validation and historical replay
--------------------------------

Magnitude options ``noise_level`` and ``condition_factor`` must be finite,
nonnegative real scalars. ``perturbation_level`` also retains Python's
coordinatewise vector amplitudes: a finite, nonnegative vector of length one
or the problem dimension. Its dimension is checked when the problem is known.
Finite lists/tuples and NumPy vectors follow the same arithmetic. ``mesh_size``
must be finite and strictly positive; ``nan_rate`` must be finite and between
zero and one. Python accepts NumPy real scalars, but not booleans or arrays for
scalar settings. These checks reject an invalid configuration, not the
intentional nonfinite observations produced by a feature such as ``random_nan``.

Option names are case-insensitive; two spellings of one name in one call or
one stage entry are rejected as a duplicate in both languages (legacy archives
store canonical names and are unaffected). A boolean ``n_runs`` is rejected
like a boolean magnitude.

Execution or replay of an old invalid configuration now fails explicitly. This
includes boolean magnitudes (formerly accepted as integers), negative
``perturbation_level`` and nonfinite magnitudes; no replacement value is guessed.
Loading retained numerical results for reporting does not recreate the feature
and remains separate from replaying its executable configuration.

Python accepts case-insensitive ``mesh_type`` on fresh input and stores its
normalized spelling in the effective specification. Historical native/refined
configurations need separate treatment: older Python code accepted mixed-case
spellings but executed the absolute grid for all of them. The compatibility
reader preserves that actual grid as ``absolute`` instead of silently changing
an archived experiment. It does not rewrite the historical declaration or the
source archive. Fresh ``Feature('quantized', mesh_type='RELATIVE')`` correctly
means the relative grid; old serialized effective ``'RELATIVE'`` retains the
absolute grid that was originally evaluated.

New ``options_user.pkl`` dictionaries carry ``schema='options_user-v2'`` in
addition to the original input. This distinguishes raw current input from old
unmarked flat archives when using ``legacy_compat.replay_arguments``; both the
``feature_name`` shorthand and structured ``feature`` route are supported.
Use ``options_refined.pkl`` to replay the resolved defaults and run count.

Adding a stage
--------------

A stage has six value channels: observed and reference values for the objective,
nonlinear inequalities, and nonlinear equalities. Before adding a stage, specify
all six policies explicitly, including coordinate transport, stochastic streams,
and whether reference evaluations call user code. Register its options and
frozen seed code in ``feature_definitions.py``, its view in ``composition.py``,
and its single-stage behavior in ``opclasses.py``. Preserve the existing seed
codes and legacy streams; a new policy needs a new version identifier.

Add an independent expected-value case to ``test_stage_channel_contracts.py``.
Its registry check requires every built-in kind to declare its channel behavior.
Also cover nonconstant coordinate transformations, callback counts, constraint
shape, history budgets, serialization, and MATLAB compatibility where applicable.
The constant-value matrix checks value policy; it does not replace these tests.
