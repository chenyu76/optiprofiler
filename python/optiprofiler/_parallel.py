"""Ordered benchmark tasks with explicit worker-loss and abort cleanup."""
from concurrent.futures import ProcessPoolExecutor, as_completed
import time


def run_tasks(function, args, n_jobs, initializer, initargs):
    executor = ProcessPoolExecutor(max_workers=n_jobs, initializer=initializer, initargs=initargs)
    # Eager startup lets the manager observe every worker sentinel before a
    # task can kill a newly spawned worker. Python 3.8 already starts eagerly.
    if hasattr(executor, '_safe_to_dynamically_spawn_children'):
        executor._safe_to_dynamically_spawn_children = False
    futures = {}
    owned = set()
    results = [None] * len(args)
    try:
        for index, arg in enumerate(args):
            future = executor.submit(function, *arg)
            futures[future] = index
            # Python 3.8 has no public executor termination API. Retain only
            # this executor's process handles, even if its manager later exits.
            owned.update((executor._processes or {}).values())
        for future in as_completed(futures):
            results[futures[future]] = future.result()
    except BaseException:
        owned.update((executor._processes or {}).values())
        for future in futures:
            future.cancel()
        # shutdown(wait=True) alone waits for running tasks after cancellation.
        # Terminate our workers first; never enumerate caller-owned children.
        for process in owned:
            if process.is_alive():
                process.terminate()
        deadline = time.monotonic() + 5
        for process in owned:
            process.join(max(0, deadline - time.monotonic()))
        for process in owned:
            if process.is_alive():
                process.kill()
        raise
    finally:
        executor.shutdown(wait=True)
    return results
