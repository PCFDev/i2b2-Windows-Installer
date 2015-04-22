. .\config-i2b2.ps1
. .\common.ps1
. .\functions.ps1
. .\configuration.ps1

function createDatabase($dbname){
    echo "Creating database: $dbname"

    $sql = interpolate_file $__skelDirectory\i2b2\data\$DEFAULT_DB_TYPE\create_database.sql DB_NAME $dbname

    $cmd =  $conn.CreateCommand()
    
    $cmd.CommandText = $sql

    $cmd.ExecuteNonQuery() > $null

    $cmd.Dispose()

    echo "$dbname created"

}

function createUser($dbname, $user, $pass, $schema){
    echo "Creating user: $user"

    $sql = interpolate_file $__skelDirectory\i2b2\data\$DEFAULT_DB_TYPE\create_user.sql DB_NAME $dbname |
        interpolate DB_USER $user |
        interpolate DB_PASS $pass |
        interpolate DB_SCHEMA $schema    

    $cmd =  $conn.CreateCommand()
    
    $cmd.CommandText = $sql

    $cmd.ExecuteNonQuery() > $null

    $cmd.Dispose()

    echo "$user created"
}

function installShrineData{

    echo "Creating Shrine Database..."

    #createDatabase $SHRINE_DB_NAME

    echo "Shrine Database created."
    echo "Creating Shrine DB user..."

    #createUser $SHRINE_DB_NAME $SHRINE_DB_USER $SHRINE_DB_PASS $SHRINE_DB_SCHEMA

    echo "Shrine DB User created."
    echo "updating i2b2 Ontology and CRC Database Tables..."
<#
    $sql = interpolate_file $__skelDirectory\shrine\$DEFAULT_DB_TYPE\configure_hive_db_lookups.sql DB_NAME $HIVE_DB_NAME |
        interpolate I2B2_DOMAIN_ID $I2B2_DOMAIN |
        interpolate SHRINE $SHRINE_DB_PROJECT |
        interpolate I2B2_DB_SHRINE_ONT_DATABASE.I2B2_DB_SCHEMA $SHRINE_DB_SCHEMA |
        interpolate java:/I2B2_DB_SHRINE_ONT_DATASOURCE_NAME $SHRINE_DB_DATASOURCE |
        interpolate SQLSERVER $DEFAULT_DB_TYPE.ToUpper() |
        interpolate I2B2_DB_CRC_DATABASE.I2B2_DB_SCHEMA $CRC_DB_SCHEMA |
        interpolate java:/I2B2_DB_CRC_DATASOURCE_NAME $CRC_DB_DATASOURCE

    $cmd = $conn.CreateCommand()

    $cmd.CommandText = $sql

    $cmd.ExecuteNonQuery() > $null
    #>
    $sql = interpolate_file $__skelDirectory\shrine\sqlserver\configure_pm.sql DB_NAME $PM_DB_NAME |
        interpolate SHRINE_USER $SHRINE_DB_USER |
        interpolate SHRINE_PASSWORD_CRYPTED $SHRINE_DB_PASS |
        interpolate SHRINE $SHRINE_DB_PROJECT |
        interpolate SHRINE_IP $_SHRINE_IP |
        interpolate SHRINE_SSL_PORT $_SHRINE_SSL_PORT
    
    $cmd = $conn.CreateCommand()

    $cmd.CommandText = $sql

    $cmd.ExecuteNonQuery() > $null
    
    $cmd.Dispose()

    echo "i2b2 Ontology and CRC Database Tables updated."

}


echo "Starting Shrine Data Installation"
echo "Verifing connection to database server"

$conn = New-Object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = "Server=$DEFAULT_DB_SERVER;Database=master;Uid=$DEFAULT_DB_ADMIN_USER;Pwd=$DEFAULT_DB_ADMIN_PASS;"
   
 
try{    
    $conn.Open() > $null    
    echo "Connected to $DEFAULT_DB_SERVER"
}
catch {
    echo "Could not connect to database server: $DEFAULT_DB_SERVER"
    exit -1
}

installShrineData


$conn.Close()
$conn.Dispose()

echo "Shrine Data Installation Completed"