timestamp=$(date +"%Y-%m-%d-%H-%M-%S")
ping_status=$(curl --silent --output /dev/null --write-out "%{http_code}" -X 'GET'   'https://betapi.agatha-budget.fr/ping'   -H 'accept: application/json'   -d '')
echo ${ping_status}

case ${ping_status} in 
    *200*)
        echo ${timestamp}_RAS_beta >> /home/erica/ping.txt
        ;;
    *)
        echo ${timestamp}_PROBLEM_beta >> /home/erica/ping.txt
        systemctl restart betabackend
        ;;
esac

ping_status=$(curl --silent --output /dev/null --write-out "%{http_code}" -X 'GET'   'https://api.agatha-budget.fr/ping'   -H 'accept: application/json'   -d '')
echo ${ping_status}

case ${ping_status} in 
    *200*)
        echo ${timestamp}_RAS_default >> /home/erica/ping.txt
        ;;
    *)
        echo ${timestamp}_PROBLEM_default >> /home/erica/ping.txt
        systemctl restart backend
        ;;
esac