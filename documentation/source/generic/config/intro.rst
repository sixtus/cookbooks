Introduction to Chef
====================

This manual describes configuration management and systems integration with
`Chef`_. **Chef** is an open source systems integration framework where you
write source code to describe how you want each part of your infrastructure to
be built, then apply those descriptions to your servers. The result is a fully
automated infrastructure: when a new server comes on line, the only thing you
have to do is tell Chef what role it should play in your architecture.

.. rubric:: How does it work?

Chef works by allowing you to write *recipes* that describe how you want a part
of your server (such as nginx, MySQL or MongoDB) to be configured. These
recipes describe a series of *resources* that should be in a particular state -
for example, packages that should be installed, services that should be
running, or files that should be written. We then make sure that each resource
is properly configured, only taking corrective action when it's neccessary. The
result is a safe, flexible mechanism for making sure your servers are always
running exactly how you want them to be.

Chef has been built directly on top of `Ruby`_, a dynamic, open source
programming language. This means that no matter how complicated your
infrastructure may be, or how quickly the state of the art in systems
architectures moves, you'll be able to write a Chef recipe that can deal with
it.

This chapter will explain Chef from a top-down perspective. First the Chef
repository layout and its generic parts are explained. Then, starting from the
high-level concept of a node we will make our way down to recipes, resources,
attributes and libraries.

.. _Chef: http://www.opscode.com/chef/
.. _Ruby: http://www.ruby-lang.org
