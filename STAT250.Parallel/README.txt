Paralleling Computing arrival delays mean, median.

1, In R with parallel packages, it is trivial. But basically runtime/cores num is linear.
2, Adapted from Duncan's AirlineDelays package, change from pthread to OpenMP, but seems to be pretty slow, might need optimization.
3, More to come.. Hadoop Java API version is presented by Duncan; working on streaming mode.