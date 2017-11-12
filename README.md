# elastalert-docker-container
elastalert in a docker container

docker pull command:-  ```docker pull nsvijay04b1/elastalert-docker-container```

image location :-         https://github.com/nsvijay04b1/elastalert-docker-container


This docker image is a customized version  of krizsan/elastalert-docker image with below fixes 

-    building image was failing due to urllib3 dependency
-    changes in directory/file structure to sync with standard open source tools(like /etc/elastalert for config , /var/logs/elastalert for logs, /opt/elastalert-server for application itself) 
-    option to enable proxy if corporate netowrk used, uncomment proxy part to use it with correct proxy url updated.
-    updated rules file.


This comes with a sample rule which is tested working fine "severity_frequency.yaml" in rules folder of the container.
This rule looks for severity="ERROR" if occured 20 times in 1 hours time and send alert to email and repeat alert every 10 mins.

ElastAlert queries elasticsearch every 60 seconds to (1) get data and matches it with (2) rules and then (3) triggers alert based on the rules,  (1),(2),(3) steps in short what the elastalert is designed to do.

It has a start script 'start-elastalert.sh" which does below 

-  Start Supervisor daemon as primary process which starts elasticalert application based on pre flight checks like below.
-  If SET_CONTAINER_TIMEZONE  was set "True" in dockerfile, Container timezone is modified, else, default to TZ Europe/Stockholm
-  checks and waits until a connection to elasticsearch is established only then applications is started. 
-  Logs are stored at ${LOG_DIR}/elastalert_stderr.log,${LOG_DIR}/elastalert_supervisord.log





Default elasticsearch index for elastalert is ```'elastalert_status'```.



For more info or help how elastalert works , please visit official repo https://github.com/Yelp/elastalert 

If you want to use offical image as is without customization, please check  https://hub.docker.com/r/bitsensor/elastalert/ 

For detailed documentation of the elastalert application, please visit  https://elastalert.readthedocs.org 

To integrate elastalert(backend) application to a front-end plugin on top of kibana, please check ![this]




