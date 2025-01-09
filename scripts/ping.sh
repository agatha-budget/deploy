my=$(curl --silent --output /dev/null --write-out "%{http_code}" -X 'GET'   'https://betapi2.agatha-budget.fr/ping'   -H 'accept: application/json'   -d '')
echo ${my}

case ${my} in 
    *200*)
        echo "RAS"
        ;;
    *)
        echo "PROBLEM"
        systemctl restart betabackend
        ;;
esac

my=$(curl --silent --output /dev/null --write-out "%{http_code}" -X 'GET'   'https://api2.agatha-budget.fr/ping'   -H 'accept: application/json'   -d '')
echo ${my}

case ${my} in 
    *200*)
        echo "RAS"
        ;;
    *)
        echo "PROBLEM"
        systemctl restart backend
        ;;
esac