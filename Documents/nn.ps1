#to fetch azure policies
az login   

az account set --subscription 5ec066e4-9c88-444b-84c7-657da8c158c7

az policy state summarize

az policy state list

$allPolicies = az policy state summarize

$odata = $allPolicies | ConvertFrom-Json
$odata | FT

foreach($data in $odata){
$pAssigns=$data.policyAssignments
$pAssigns | FT

$policyDefinations = $pAssigns.policyDefinitions
$policyDefinations | Format-Table

$result = $policyDefinations.results
$result |FT

}

foreach($data in $odata)
{
$results=$data.results
$results | FT
}

Get-AzPolicyStateSummary
az policy state summary
