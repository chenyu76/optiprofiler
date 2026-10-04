"""Shared reference-history failure policy for feature recorders."""

import logging
import warnings
import numpy as np


def reference_maxcv_or_nan(evaluate, x):
    """Keep an unavailable history value, with the underlying failure visible."""
    try:
        return evaluate(x)
    except Exception as error:
        message = (f'Reference constraint violation could not be recorded: '
                   f'{type(error).__name__}: {error}')
        # Solver execution suppresses Python warnings; its queue logger must
        # still retain this failure in the benchmark log.
        logging.getLogger(__name__).warning(message)
        warnings.warn(message, RuntimeWarning, stacklevel=3)
        return np.nan
