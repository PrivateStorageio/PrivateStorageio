Monitoring
==========

This section gives a high-level overview of the PrivateStorageio monitoring efforts.


Goals
`````

Alerting
  Something might break soon, so somebody needs to do something.

Comparing over time or experiment groups
  Is our service slower than it was last week? Does database B answer queries faster than database A?

Analyzing long-term trends
  How big is my database and how fast is it growing? How quickly is my daily-active user count growing?


Introduction to our dashboards
``````````````````````````````

We have two groups of dashboards: Requests (external view, RED method) and Resources (internal view, USE method).

Services and their dependencies can be visualized as a tree from external-facing to internal systems.
We order our dashboards like a breadth-first-search of that tree.
This makes it easier to understand dependencies and faster to trouble shoot when a high-latency problem on a low-level service bubbles up.


Meaning of our metrics
``````````````````````

Google's *Monitoring Distributed Systems* book about what they call the `Four Golden Signals <https://sre.google/sre-book/monitoring-distributed-systems/#xref_monitoring_golden-signals>`_ has a great explanation and definition of useful metrics:

Latency
  Requests, but also errors take time, so don't discard them.

Traffic
  What constitutes "Traffic" depends on the nature of your system.

Errors
  (The *rate* of ) failed requests.

Saturation
  How "full" your service is.  Take action (i.e. page a human) before service degrades.

"If you measure all four golden signals and page a human when one signal is problematic (or, in the case of saturation, nearly problematic), your service will be at least decently covered by monitoring."


RED method for services ("request-scoped", "external view")
```````````````````````````````````````````````````````````

Request rate, Errors, Duration (+ Saturation?)

* Instrument everything that takes time and could fail
   * "In contrast to logging, services should instrument every meaningful number available for capture." (Peter Bourgon)

* Plot 99th percentile, 50th percentile and average
   * 50th and average should be close - else something is wrong
   * Averages sum neatly - Service latency average should be sum of child service latencies


USE method for resources ("resource-scoped", "internal view")
`````````````````````````````````````````````````````````````

Utilization, Saturation, Errors:

* CPUs
   * Saturation (Idea: max saturation value per machine, since our load is mostly single-core)
* Memory
   * Saturation
* Network
   * Saturation
* Network
* Disks
   * Storage capacity
   * I/O saturation

* Software resources
   * File descriptors


Logging
```````

Peter Bourgon has a lot of wise things to say about logging in `his brilliant article Logging v. instrumentation <https://peter.bourgon.org/blog/2016/02/07/logging-v-instrumentation.html#:~:text=Instrumentation%20is%20for%20all%20remaining,meaningful%20number%20available%20for%20capture.>`_.

* "[S]ervices should only log actionable information. That includes serious, panic-level errors that need to be consumed by humans, or structured data that needs to be consumed by machines."
* "Logs read by humans should be sparse, ideally silent if nothing is going wrong. Logs read by machines should be well-defined, ideally with a versioned schema."
* "A (service) never concerns itself with routing or storage of its output stream. It should not attempt to write to or manage logfiles. Instead, each running process writes its event stream, unbuffered, to stdout."
* "Finally, understand that logging is expensive." and "Resist the urge to log any information that doesn’t meet the above criteria. As a concrete example, logging each incoming HTTP request is almost certainly a mistake."


Alerts
``````

Nobody likes being alerted needlessly.
Don't give *Alert Fatigue* a chance!

Rob Ewaschuk gives some great advice in Google's `Monitoring Distributed Systems <https://sre.google/sre-book/monitoring-distributed-systems/#tying-these-principles-together-nqsJfw>`_: "a good starting point for writing or reviewing a new alert":

- Only alert on actionable and urgent events that negatively affect users consistently and that cannot wait & cannot be automated.
- Page one person at a time.
- Do only page on novel problems.


See also
````````

This methodology was inspired by (inter alia)

* `Brendan Gregg: The Utilization Saturation and Errors (USE) Method. 2007. <http://www.brendangregg.com/usemethod.html>`_
* `Rob Ewaschuk, Betsy Beyer: Monitoring Distributed Systems. 2017. <https://sre.google/sre-book/monitoring-distributed-systems/>`_ The Four Golden Signals SRE Book by Google. 
* `Tom Wilkie (Kausal): The RED method. How To Instrument Your Services. Feb 2018. <https://www.youtube.com/watch?v=9dRSYjBPaZM>`_
* `Steve Mushero: How to Monitor the SRE Golden Signals. Nov 10, 2017. <https://steve-mushero.medium.com/linuxs-sre-golden-signals-af5aaa26ebae>`_

* `Cindy Sridharan: Logs and Metrics. Apr 30, 2017. <https://copyconstruct.medium.com/logs-and-metrics-6d34d3026e38>`_
* `Peter Bourgon: Logging v. instrumentation. 2016 02 07. <https://peter.bourgon.org/blog/2016/02/07/logging-v-instrumentation.html#:~:text=Instrumentation%20is%20for%20all%20remaining,meaningful%20number%20available%20for%20capture.>`_ What not to log.

