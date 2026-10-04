"""Shared reference-history failure policy for feature recorders."""

import warnings
import numpy as np


def reference_maxcv_or_nan(evaluate, x):
    """Keep an unavailable history value, with the underlying failure visible."""
    try:
        return evaluate(x)
    except Exception as error:
        warnings.warn(
            f'Reference constraint violation could not be recorded: '
            f'{type(error).__name__}: {error}', RuntimeWarning, stacklevel=3,
        )
        return np.nan
