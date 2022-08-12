#install postgresql
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
FOLDER_PATH=$(realpath $SCRIPT_DIR/./acdc)
echo $FOLDER_PATH
git clone https://github.com/PharmaLedger-IMI/acdc-components.git $FOLDER_PATH
helm upgrade --install --wait --timeout=600s postgresql bitnami/postgresql
export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
kubectl port-forward --namespace default svc/postgresql 5432:5432 &
sleep 10s
cd "$FOLDER_PATH/backoffice-backend/lib/sql/acdc/install"
PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 -f setup.sql -f acdc2.sql

rm -rf $FOLDER_PATH
pid=$(lsof -i :5432 | sed -n '2 p' | awk '{print $2}')
kill $pid

helm upgrade --install --wait --timeout=600s dfm-backend pharmaledger-imi/dfm-backend
