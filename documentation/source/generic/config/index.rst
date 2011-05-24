Configuration Management
========================

Configuration management is the detailed recording and updating of information
that describes an enterprise's hardware and software. Configuration Management
is mostly a policy driven process:

- Set policy by documenting problems
- Execute policy by writing code
- Audit policy by confirming results
- Test policy by repeating the process

Principles of configuration management
--------------------------------------

Declarative
  Tell the system what to do, not how to do it.

Abstract
  Take care of the details.

Idempotent
  Only take action if necessary.

Convergent
  Each configured resource becomes compliant with policy over time.

Contents
--------

.. toctree::
   :maxdepth: 1

   intro
   repository
   nodes
   roles
   databags
   cookbooks/index
