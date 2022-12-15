

function extract_data{
    Write-Output "Login to account to extract data"
    az login
    az account set --subscription 5ec066e4-9c88-444b-84c7-657da8c158c7
    $allstates = az policy state list --all
    $dd=$allstates|ConvertFrom-Json
    foreach($d in $dd){
    $splittedResourceName = $d.resourceId.split("/")[-1]
    # $splittedResourceType = $d.resourceType.split("/")[-1]
    $d.resourceId=$splittedResourceName
    # $d.resourceType=$splittedResourceType
    }
    # $finaloutput = $dd |Sort-Object complianceState|Format-Table policyAssignmentName,policyDefinitionName,resourceId,resourceType,complianceState -groupby complianceState
    return $dd
}
function connect_to_DB{
Write-Output "Login to account to get connected to DB"
az login
az postgres flexible-server connect -n acheta11  -u acheta_pgsql@acheta11 -p Nish@123 
}
function create_table{
    az postgres flexible-server execute --admin-password Nish@123 --admin-user acheta_pgsql@acheta11 --name acheta11 --querytext `
    "create table resources (resource varchar(100) primary key);"

    az postgres flexible-server execute --admin-password Nish@123 --admin-user acheta_pgsql@acheta11 --name acheta11 --querytext `
    "create table definitions (definition varchar(100) primary key);"

    az postgres flexible-server execute --admin-password Nish@123 --admin-user acheta_pgsql@acheta11 --name acheta11 `
    --querytext `
    "create table assignments(assignment varchar(100),resource varchar(100) references resources(resource) on delete cascade,definition varchar(100) references definitions(definition) on delete cascade,compliance varchar(15), Primary key(assignment,resource,definition)  );"
}
function insert_table($out){
    # trigger function
    az postgres flexible-server execute --admin-password Nish@123 --admin-user acheta_pgsql@acheta11 --name acheta11 --querytext `
    "CREATE OR REPLACE FUNCTION befo_insert() RETURNS TRIGGER AS `$my_table`$ BEGIN  IF new.re_name NOT IN(select * from resorces) THEN INSERT INTO resorces(re_name) VALUES (new.re_name);END IF; IF new.def_name NOT IN(select * from definitions) THEN INSERT INTO definitions(def_name) VALUES (new.def_name); END IF; RETURN NEW; END;`$my_table`$ LANGUAGE plpgsql;"

    # trigger
    az postgres flexible-server execute --admin-password Nish@123 --admin-user acheta_pgsql@acheta11 --name acheta11 --querytext `
    "CREATE TRIGGER insert_into_res BEFORE INSERT ON assignments FOR EACH ROW EXECUTE PROCEDURE befo_insert();"

    foreach($o in $out){
        $a =$o.policyAssignmentName
        $d = $o.policyDefinitionName
        $re = $o.resourceId
        $c = $o.complianceState
        az postgres flexible-server execute --admin-password Nish@123 --admin-user acheta_pgsql@acheta11 --name acheta11 --querytext `
             "insert into assignments(assignment,resource,definition,compliance) values('$($a)','$($re)','$($d)','$($c)');"
    }

    
}

$out=extract_data
# $out
connect_to_DB
create_table
insert_table($out)   
