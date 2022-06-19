#/bin/bash
#################################################################################
# wood.hu@azukisystems.com
# 09/2012
# bwctl-ultimate
#################################################################################
CURRENTPPID=$$
argv=($*)
argc=${#argv[*]}
progname=$0
mute=1

LocalCDN="n.peermeta.mobi o.peermeta.mobi p.peermeta.mobi"

usage() {
  echo " *******************************************************************************************************************"
  echo " usage:"
  echo " $progname <ethernet|airport|fw> <rate_limit:rate_limit_timer|rate_limit-rate_limit:rate_limit_step:rate_limit_timer>"
  echo "   for example: $progname airport 500:15 50-400:25:30 450:20"
  echo "                $progname ethernet 800:15  500-100:50:30  200-300:25:20"
  echo ""
  echo "   parameter #2 is the interface that corresponse to ICS section 'To computers using' checkbox."
  echo " *******************************************************************************************************************"
  exit 99
}

if [ $argc -le 0 ]; then
  usage $progname
elif [ $argc -le 1 ]; then
##################################################################################
################################# EDIT EDIT EDIT #################################
##################################################################################
###### two options to specify the bandwidth limit ######
###### this is option 1, option 2 is providing parameter to command line ######
# *NOTE* rates are in kByte/s when working with this
###### the first two rates will enable device to switch from video to audio only.
BW[0]=50
BW[1]=20
# *NOTE* you can add more index, just don't create a hole in the array.
BW[2]=100
BW[3]=200
BW[4]=300
BW[5]=400
BW[6]=500
#BW[7]=150
#BW[8]=200
#BW[9]=250
#BW[10]=300

##################################################################################
################################ DO NOT EDIT BELOW THIS LINE #####################
##################################################################################
fi

checkInterface() {
  case "$1" in
    a*|ai*|air*|airport*|wifi*) SHARED_INTERFACE=airport;;
    e*|et*|eth*|ether*|ethernet*) SHARED_INTERFACE=ethernet;;
    f*|fw*|firewire)  SHARED_INTERFACE=firewire;;
    *)
      echo " *****************************************************************************************************" 
      echo " ~~~~~  ${progname} ${argv[0]} <<< is invalid; valid interface=> airport, ethernet, firewire ~~~~~"
      echo " ******************************************************************************************************"
      usage $progname;;  
  esac
  #lets take care of this form eth:192.168.2.2/32 and eth:192.168.2.2-10/32
  #IPA store all ip.
  #IPAMASK store the mask.
  local ipline=$(echo $1 | cut -d\: -f2)
  IPAMASK=$(echo $ipline | cut -d\/ -f2)
  echo $ipline | grep -- "-" > /dev/null
  if [ $? -eq 0 ]; then
    #lets handle range
    local oct=($(echo $ipline | cut -d\- -f1 | sed 's/\./\ /g'))
    local end=$(echo $ipline | cut -d\- -f2 | cut -d\/ -f1)
    NUM_PIPE=0
    for((i=${oct[3]};i<=$end;i++))
    do
      IPA[$NUM_PIPE]="${oct[0]}.${oct[1]}.${oct[2]}.$i"
  #    echo "IPA=${IPA[$NUM_PIPE]}"
      ((NUM_PIPE++))
    done
 #   echo "mask:${IPAMASK}"
 #   exit 111
  else
    local oct=$(echo $ipline | cut -d\/ -f1)
    #echo "oct:$oct"
    #echo "mask:${IPAMASK}"
    IPA[0]=$oct
    NUM_PIPE=1
#    exit 111
  fi
  return 0
}

setupRateLimit() {
if [ $argc -gt 1 ]; then
  #how about allowing option to specify bandwidth:timer for parameter
  #bwctl-ultimate 20:120 30:90 40:60 50:60 60:30 75:30 100:30 125:30 150:30 175:30 200:30
  # and a mix with range bwctl-ultimate 500:15 50-500:25:30 500-50:50:30
  #shift to account for interface parameter
  shift
  BWLIST=$*
  count=0
  for a in ${BWLIST}
  do
    echo "$a" | grep -- "-" > /dev/null
    if [ $? -eq 0 ]; then
      range=($(echo $a | cut -d: -f1 | sed 's/\-/\ /'))
      step=$(echo $a | cut -d: -f2)
      timer=$(echo $a | cut -d: -f3)
      #echo "range:${range[0]} ${range[1]} step:$step timer:$timer"
      if [ "$step" -lt 0 ] || [ ${range[0]} -gt ${range[1]} ]; then
        #step down
        if [ "$step" -lt 0 ]; then
          step=$((step * -1))
        fi
        for((i=${range[0]}; i>=${range[1]}; i-=$step))
        do
          BW[$count]=$i
          BWTIMER[$count]=$timer
          ((count++))
        done
      else
        #step up
        for((i=${range[0]};i<=${range[1]};i+=$step))
        do
          BW[$count]=$i
          BWTIMER[$count]=$timer
          ((count++))
        done
      fi
    else  
      BW[$count]=$(echo $a | cut -d: -f1)
      BWTIMER[$count]=$(echo $a | cut -d: -f2)
      ((count++))
    fi
  done
fi
}

#trap is not support on this old mac (10.6.8) per man page on bash.
#leaving it here since future version may support it.
trap 'delPipe;echo "cleanup done by trap";exit 1' 15

#since no support for trap, using this workaround to do the cleanup.
setupTrapWorkaround() {
  sudo cat << EOF_MARK > trapworkaround
#!/bin/bash
pidtomon=\$1
SHARED_INTERFACE=\$2
for((;;)){
  ps -p \$pidtomon
  if [ \$? -eq 1 ]
  then
    sudo ipfw delete 1
    #remove itself after done
    rm \$0
    exit 0
  else
    sleep 1
  fi

  if [ "$SHARED_INTERFACE" == "airport" ]; then
    pid=\$(ps aux | awk '\$11 ~ /bootpd/{print \$0}')
    if [ "\$pid" == "" ]; then
      echo "kill parent pid:\$pidtomon"
      kill \$pidtomon
    fi
  fi

}
EOF_MARK
  while [ ! -e trapworkaround ]
  do
    sleep 1
  done
  sudo chmod a+x trapworkaround
  nohup ./trapworkaround $CURRENTPPID $SHARED_INTERFACE > /dev/null 2> /dev/null < /dev/null &
}

delPipe() {
  #issue delete only when we see rules set.
  for((i=1;i<=$NUM_PIPE;i++))
  do
  
    sudo ipfw show $i 2> /dev/null
    if [ $? -eq 0 ]; then
      sudo ipfw delete $i
    fi
  done
}

setBandwidth() {
  local bw=$1
  local i=0
  local rval[0]=0
  local rv=0
  for((i=1;i<=$NUM_PIPE;i++))
  do
    sudo ipfw pipe $i config bw ${bw}kByte/s && rval[$i]=$?
  done
  for((i=1;i<=$NUM_PIPE;i++))
  do
  ((rv+=${rval[$i]}))
  done
  #it'll be more than 255 unless some some change the number of hosts
  #put it in here to protect sending bogus status value.
  if [ $rv -gt 255 ]; then
    rv=255
  fi
  return $rv
}

setFilter() {
  local rv=0
  local clientIPA=($(getAllClient))
  if [ $? -ne 0 ]; then
    rv=1
    return $rv
  fi
  local rval[0]=0
  local sval[0]=0
  
  #account for clients that are already gone for cleanup purpose
  if [ $NUM_PIPE -lt ${#clientIPA[*]} ];then
    NUM_PIPE=${#clientIPA[*]}
  fi
  for((i=0;i<${#clientIPA[*]};i++))
  do
    #experimenting with multiple pipe
    sudo ipfw add 1 pipe $((i+1)) dst-ip ${clientIPA[$i]}/32 && rval[$i]=$?
    sudo ipfw add 1 pipe $((i+1)) src-ip ${clientIPA[$i]}/32 && sval[$i]=$?
  done
  for((i=0;i<${#clientIPA[*]};i++))
  do
    ((rv +=${rval[$i]}))
    ((rv += ${sval[$i]}))
    if [ $rv -gt 255 ]; then
      rv=255
      return $rv
    fi
  done
  return $rv
}

getShareNetInfo() {
  local interface=$1
  local interfacename=""
  case "$interface" in
    airport)  interfacename="en0";;
    ethernet)   interfacename="en0";;
    firewire)    interfacename="fw0";;
  esac
  ifconfig $interfacename | awk '/inet\ (10|192)/{print "ip:"$2,"subnet:"$4,"broadcast:"$6}'
}

getRealInterfaceName() {
  case "$1" in
    airport)  interfacename="en0";;
    ethernet)   interfacename="en0";;
    firewire)    interfacename="fw0";;
  esac
  echo "$interfacename"
}

#can only detect airport as it uses bootpd
#detect the removal of bootpd.
isICSon() {
  local retval=0
  if [ "$SHARED_INTERFACE" == "airport" ]; then
    pid=$(ps aux | awk '$11 ~ /bootpd/{print $0}')
    if [ -n "$pid" ]; then
      retval=1
    fi
  else
    if [ "$retval" -ne 1 ]; then
      retval=$(ifconfig $(getRealInterfaceName $SHARED_INTERFACE) | awk 'BEGIN{retval=0}/inet\ (10|192)/{retval=1}END{print retval}')
    fi
  fi
  echo $retval
}

getAllClient() {
  local retval=0
  #for internet sharing over ethernet, client ip is statically assigned by default.
  #the list needs to be generated
  #for internet sharing over wifi/airport, client ip is offered with dhcp.
  if [ $SHARED_INTERFACE == "airport" ]; then
    awk '/ip_address/{print substr($0,index($0,"=")+1)}' /var/db/dhcpd_leases
  else
    #generate list if it doesn't exist
    if [ "${IPA[*]}" == "" ];then
      #getShareNetInfo return "ip:<ip> subnet:<subnet> broadcast:<broadcast>"
      #discount interface ip.
      IFS=\ 
      oct=($(echo $(getShareNetInfo $SHARED_INTERFACE) | \
	awk '{ipline=substr($1,index($1,":")+1);split(ipline,A,"."); ipline2=substr($3,index($3,":")+1);split(ipline2,B,"."); print A[1],A[2],A[3],A[4]+1,B[4]-1 }'))
      if [ "${oct[0]}" == "" ] || [ "${oct[1]}" == "" ] || [ "${oct[2]}" == "" ] || [ "${oct[3]}" == "" ] || [ "${oct[4]}" == "" ]; then
        # echo "interface $(getRealInterfaceName $SHARED_INTERFACE) does not have any ip address; is ICS on?"
        retval=1
        return $retval
      fi
      local j=0
      for((i=${oct[3]};i<=${oct[4]};i++))
      do
        #hole in the array, but okay.
        IPA[$j]="${oct[0]}.${oct[1]}.${oct[2]}.$i"
        ((j++))
      done
    fi
    for((i=0;i<${#IPA[*]};i++))
    do
      printf "%s " ${IPA[$i]}
    done
 
  fi
  return $retval
}

#if number of clients change, echo 1
#else echo 0 for no change
detectClientChange() {
  local retval=0
  if [ x"$oldCheckSum" == x ]
  then
    oldCheckSum=$(echo $(getAllClient)|md5)
  fi

  currentCheckSum=$(echo $(getAllClient)|md5)

  if [ "$oldCheckSum" != "$currentCheckSum" ]
  then
    echo "1"
    retval=1
  else
    echo "0"
    retval=0
  fi 
  oldCheckSum=$currentCheckSum
  return $retval
}

printSummary() {
  printf "\n  ************************************* SUMMARY *********************************************\n"
  printf "  Interface shared = $SHARED_INTERFACE\n"
  printf "  Rate limit list [rate:timer] = "
  for((i=0;i<${#BW[*]};i++))
  do
    printf "[%d:%d] " ${BW[$i]} ${BWTIMER[$i]}
  done

  printf "\n  Rate limit set for clients = "
  for a in $(getAllClient)
  do
    if [ -n $a ]; then
      printf "%s " $a
    fi
  done
  printf "\n  ********************************************************************************************\n\n"

}

#system_profiler takes about 30 seconds to complete.
#system_profiler SPAirPortDataType is a lot faster for our need.
getVirtualSSID() {
  local ssid=""
  local ssidfile="/tmp/virtualSSID"
  if [ "x$virtualSSID" == "x" ]; then 
    #no environment variable set.  let's get it manually
    if [ -e $ssidfile ]; then
      while [ "$ssid" == "" ]
      do
        ssid=$(cat $ssidfile)
        sleep 1
      done
    else
      lockfile $ssidfile.lock
      ssid=$(system_profiler SPAirPortDataType | egrep -B 5 "Network Type: Wi-Fi Internet Sharing" | head -1 | cut -d: -f1 > $ssidfile && cat $ssidfile)
      rm -f $ssidfile.lock
    fi
      echo $ssid
  else
    echo $virtualSSID
  fi
}

#Mark in local CDN http access_log the rate that we are limiting to
markBandwidthOnCDN() {
  local bw=$1
  for a in ${LocalCDN}
  do
    if [ "$bw" == "" ]; then
      curl --range 0-0 --user-agent " bandwidth limit lifted " $a &
    else
      curl --range 0-0 --user-agent "$bw" $a &
    fi
  done
}

#################################################################################################
############################################### init() ##########################################
#################################################################################################
init() {
  echo "init() initializing..."
  echo "init() checking interface..."
  checkInterface ${argv[0]}
  if [ $? -ne 0 ]; then
    echo "init()  - interface check failed."
    exit 2
  fi
  echo "init() setting trap workaround"
  #trap workaround setup...
  setupTrapWorkaround
 
  echo "init() checking internet sharing..."
  #is Internet Sharing On
  #this can only be check if airport is shared which use bootpd
  if [ "$SHARED_INTERFACE" == "airport" ]; then
    if [ $(isICSon) -ne 1 ]; then
      echo " >>>>> ICS is off <<<<<"
      echo " >>>>> enable by going to System preference->sharing and turn it on. <<<<<"
      exit 1
    fi
  fi

  echo "init() obtaining virtual accesspoint name"
  #start it first to speed it up as system profile takes 30 seconds or so.
  getVirtualSSID > /dev/null &

  echo "init() setting up rate limit..."
  #if $argc > 1, rate limit is specified on command line vs what statically defined within this file.
  if [ $argc -gt 1 ];then
    setupRateLimit ${argv[*]}
  fi

  #number of pipes to set up is equivalent to number of clients.
  #keep number of pipe to keep track of the number already setup for as client may come and go.
  myiplist=$(getAllClient)
  if [ $? -ne 0 ]; then
    echo "error:getAllClient return empty list, check with ifconfig $(getRealInterfaceName $SHARED_INTERFACE) to make sure it's configured with 'inet' line"
    exit 2
  fi
  
  #start fresh
  delPipe
  echo "init() setting up filter..."
  #set filter for clients
  setFilter > /dev/null
  if [ $? -ne 0 ]; then
    echo "init() setFilter error"
    echo "bailing out!"
    exit 6
  fi
  
  #now try to set virtualSSID now
  virtualSSID=$(getVirtualSSID)

  echo "init() done initialization"
}

letTheGameBegin() {
  local iteration=0
  #calculate the number of BW rate to cycle through
  num_bw_rate=${#BW[*]}
  #high_rate=$(ib=0;for bw in ${BW[*]};do ib=$((ib<$bw?$bw:$ib));done;echo $ib)
  #now that we have the high rate, hook this in later.
  #echo "bandwidth rate count:$num_bw_rate list:${BW[*]} (kByte/s)"
  #100 second
  timer_global=100

  printf "\n== * == * == * == * == * = letTheGameBegin start = * == * == * == * == * == * ==\n" 
  #rather than starting from low bandwidth, start from index=1 (325kByte/s) to start off with video
  #we probably should choose the highest BW and use that from the very beginning
  #and then follow the order in which it was entered.
  for((iteration=0;;iteration++)) {
    if [ "$(isICSon)" -ne 1 ]; then
      delPipe
      printf " >>>>>>>>>>>><<<<<<<<<<<<\n" 
      printf " >>>>>  ICS is off  <<<<<\n"
      printf " >>  Rate Limit is off <<\n"
      printf " >>>>>>>>>>>>><<<<<<<<<<<\n"
      exit 3
    fi
    if [ $(detectClientChange) -eq 1 ]; then
      printf "client added, reset filter\n"
      delPipe
      setFilter
      if [ $? -ne 1 ]; then
        echo "bailing out with setFilter failure"
        exit 4
      fi
    fi
 
    currentbw=${BW[(($iteration%$num_bw_rate))]}
    [ $mute -ne 1 ] && say "Bandwidth set to $currentbw kilo-bytes per second" &
    printf "** iteration: %3d - >>>>> current set bandwidth %4d kByte/s <<<<<" $iteration $currentbw
    setBandwidth ${currentbw}
    if [ $? -ne 0 ]; then
      echo "error in setting up Bandwidth"
      delPipe
      exit 5
    fi
    #if bw >= 1600; set sleeptimer to 30, else it'll be range from 100 down to 30
    #for tv - we want constant sleeptimer.
    #sleeptimer=$((${currentbw}*8>=1600?30:$(($timer_global - (${currentbw} * 8/200) * 10))))
    if [ "$BWLIST" == "" ]; then
      sleeptimer=120  
    else
      sleeptimer=${BWTIMER[$iteration%$num_bw_rate]}
    fi
 
    markBandwidthOnCDN "$progname restricting access point:$virtualSSID to $currentbw kBytes/sec and holding for $sleeptimer seconds"
    printf " ... switch to %4d kByte/s in ~%2d seconds from now [%s] **\n" ${BW[((($iteration+1)%${num_bw_rate}))]} $sleeptimer "`date`"
    j=$sleeptimer
    while true
    do
      printf "%d." $j
      #don't count down if timer set to low
      if [ $sleeptimer -gt 5 ]; then
        if [ $j -le 100 ]; then
          [ $mute -ne 1 ] && say "$j" &
        elif [ $j -gt 100 ] && [ $j -lt 1000 ]; then
           if [ $(($j % 10)) -eq 0 ]; then
             [ $mute -ne 1 ] && say "$j"&
           fi
        elif [ $j -gt 1000 ] && [ $j -le 10000 ]; then
          if [ $(($j % 100)) -eq 0 ]; then
            [ $mute -ne 1 ] && say "number too large to say." &
          fi
        fi
        #else if its greater than 10000, just say nothing.
      fi
      ((j--))
      sleep 1
      if [ $j -le 0 ]
      then
        break
      fi
    done
    printf "\n"
  }
  printf "\n== * == * == * == * == * = letTheGameBegin Done = * == * == * == * == * == * ==\n"
}

#################################### INIT & START #################################
declare -a BW
declare -a BWTIMER
declare -a IPA
declare NUM_PIPE=0
init
printSummary
letTheGameBegin

