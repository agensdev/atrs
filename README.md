# Attributable (working title)

This is an early POC Virtus inspired attribute gem. We might aim to make a
drop in compatible mode. (Maybe through a plugin?)

Attributable should:
* be faster than Virtus
* have no dependencies (plugins may)
* not pollute the instance level with any methods other than ones prefixed with `_`
* should be immutable in the config layer allowing subclasses or singleton classes to modify the setup
* include a plugin system
* simplify coercions through refinements
