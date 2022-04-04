#!/bin/bash

rg_component=''"rg-kubernetes-vms-001"''
ResourceGroups=$(az group list --query "[? contains(name, '$rg_component')][].{name:name}" -o tsv)
CleanedOutput=$(echo "$ResourceGroups" | tr -d '\r')

AzureResourceGroups()

{
    for i in $CleanedOutput; 
    do
        echo Querying Stage Resource Groups "'$i'";
        az configure --defaults group="$i";
        az group delete -y -n "$i" --verbose; 
        echo Resource Groups "'$i'" have been successfully deleted.
    done
}

AzureResourceGroups "$1"
