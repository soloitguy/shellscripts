#!/bin/bash
# updateDNS.sh
#
#DOMAINSUFFIX="hdp.amerisourcebergen.com"
#SUBDOMAIN="party.dev"
#ENVCONTEXT="dev" "test" "stage0" "prod0"

while getopts "d:s:e:" option
    do
        case ${option} in
        d)
          DOMAINSUFFIX=${OPTARG}
          ;;
        s)
          SUBDOMAIN=${OPTARG}
          ;;
        e)
          ENVCONTEXT=${OPTARG}
          ;;
        esac
    done

if [[ -z $DOMAINSUFFIX ]] || [[ -z $SUBDOMAIN ]] || [[ -z $ENVCONTEXT ]]
then
        echo "All input arguments are mandatory"
        exit 1
fi

#Ensure that the current context is the correct context so that we don't overwrite the improper dns entries
#for example getting the ingress controller IP from the test context and applying it to dev, stage or prod
CURRCONTEXT=$(kubectl config current-context)
if [[ $CURRCONTEXT =~ .*$ENVCONTEXT.* ]]
then
        echo $CURRCONTEXT
else
        echo "The environment parameter entered does not match the current context"
        echo 'This is the current context: ' $CURRCONTEXT
        exit 1
fi
#Get the Ingress controller public IP, the strip the quotes
INGQUOTEDIP=$(kubectl get svc nginx-ingress-nginx-ingress-controller -o json | jq '.status.loadBalancer.ingress' | jq '.[].ip')
INGRESSIP=$(sed -e 's/^"//' -e 's/"$//' <<< $INGQUOTEDIP )
echo $INGRESSIP

#Get the current DNS records to loop through to find one that matches the input arguments (i.e. party.dev) to see if it exists
DNSRECORDS=$(az network dns record-set a list --resource-group psg-management -z $DOMAINSUFFIX -o json | jq '.[].name')
for ln in $DNSRECORDS; do
  newln=$(sed -e 's/^"//' -e 's/"$//' <<< $ln)

    #if the DNS record already exists, then does it have the same IP as the ingress controller
    if [ $newln = "$SUBDOMAIN" ]; then
        #Get the IP of the DNS record that was found to compare to the ingress controller.  If they differ Update the DNS record with new IP else exit
        DNSQUOTEDIP=$(az network dns record-set a show -g psg-management -z $DOMAINSUFFIX -n $SUBDOMAIN -o json | jq '.arecords' | jq '.[].ipv4Address')
        DNSIP=$(sed -e 's/^"//' -e 's/"$//' <<< $DNSQUOTEDIP)
        if [ "$DNSIP" = "$INGRESSIP" ]; then
                echo "We have a match, no further action required"
				echo $DNSIP
				echo $INGRESSIP
                exit 0
        else
                echo "The IPs do not align, the following IPs are DNS and Ingress Controller, respectively"
                echo $DNSIP
                echo $INGRESSIP
                echo "Updating the DNS Entry to reflect the change in the Ingress Controller's public IP"
                echo "...delete existing record"
                az network dns record-set a delete -g psg-management -z $DOMAINSUFFIX -n $SUBDOMAIN --yes
                echo "...create a new record with new IP address"
                az network dns record-set a add-record -g psg-management -z $DOMAINSUFFIX -n $SUBDOMAIN -a $INGRESSIP
				echo "a new record has been created in DNS"
                exit 0
        fi
    else
        echo "."
    fi
done

#If the record never existed, then create a new
echo "Writing New Record..."
az network dns record-set a add-record -g psg-management -z $DOMAINSUFFIX -n $SUBDOMAIN -a $INGRESSIP

