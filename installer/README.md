If you want to add a new installer script, please follow the rule as below:

```
#!/bin/bash
current_dir=$(cd `dirname ${BASH_SOURCE[0]}`; pwd)
# don't use $0, because it won't work if "source /path/xxx.sh".
# current_dir=$(cd `dirname $0`}; pwd)
source $current_dir/precondition.sh


Note, please ensure you have the sudo privilege to execute the script via using yum/apt etc.
