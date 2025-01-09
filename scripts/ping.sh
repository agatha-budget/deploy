timestamp=$(date +"%Y-%m-%d-%H-%M-%S")
my=$(curl --silent --output /dev/null --write-out "%{http_code}" -X 'GET'   'https://betapi2.agatha-budget.fr/ping'   -H 'accept: application/json'   -d '')
echo ${my}

case ${my} in 
    *200*)
        echo ${timestamp}_RAS_beta >> /home/erica/ping.txt
        ;;
    *)
        echo ${timestamp}_PROBLEM_beta >> /home/erica/ping.txt
        systemctl restart betabackend
        ;;
esac

my=$(curl --silent --output /dev/null --write-out "%{http_code}" -X 'GET'   'https://api2.agatha-budget.fr/ping'   -H 'accept: application/json'   -d '')
echo ${my}

case ${my} in 
    *200*)
        echo ${timestamp}_RAS_default >> /home/erica/ping.txt
        ;;
    *)
        echo ${timestamp}_PROBLEM_default >> /home/erica/ping.txt
        systemctl restart backend
        ;;
esac