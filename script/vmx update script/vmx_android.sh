
function calculate_md5
{
	md5_value=$(md5 -q $1)

	for i in `seq 0 15`
	do
		index=$i*2       
    	array[$i]=${md5_value:$index:2}
	done

	for index in `seq 0 15`
	do
		str=${array[$index]}
		value=$((16#${str}))
		value=$(( ${value} ^ 170 ))
    	printf "0x%02x" $value >> $2
    	if [ $index != 15 ]; then
    		printf ", " >> $2
    	else
    		printf " };\n" >> $2
    	fi
	done
}

if [ $# != 4 ]; then
	echo "Usage: $0 <Update Package Directory> <Branch Root Directory> <Platform> <Version>"
	exit 1
fi

notExce(){  
diff $1/ARM/frame_buffer_api.h $1/x86/frame_buffer_api.h
if [ $? != 0 ]; then
	echo "frame_buffer_api.h for ARM and x86 version are different, please check it manually!"
	exit 1
fi

diff $1/ARM/ViewRightWebClient.h $1/x86/ViewRightWebClient.h
if [ $? != 0 ]; then
	echo "ViewRightWebClient.h for ARM and x86 version are different, please check it manually!"
	exit 1
fi

diff $1/ARM/ViewRightWebInterface.h $1/x86/ViewRightWebInterface.h
if [ $? != 0 ]; then
	echo "ViewRightWebClient.h for ARM and x86 version are different, please check it manually!"
	exit 1
fi

diff $1/ARM/frame_buffer_api.h $2/Thirdparty/voVMK/Source/frame_buffer_api.h
if [ $? != 0 ]; then
	echo "frame_buffer_api.h has changed, please check it manually!"
	exit 1
fi

diff $1/ARM/ViewRightWebClient.h $2/Thirdparty/Verimatrix/inc/ViewRightWebClient.h
if [ $? != 0 ]; then
	echo "ViewRightWebClient.h has changed, please check it manually!"
	exit 1
fi

diff $1/ARM/ViewRightWebInterface.h $2/Thirdparty/Verimatrix/inc/ViewRightWebInterface.h
if [ $? != 0 ]; then
	echo "ViewRightWebInterface.h has changed, please check it manually!"
	exit 1
fi
}

~/android-ndk-r12b/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-readelf -d $1/ARM/libViewRightVideoMarkClient.so | grep libViewRightVideoMarkClient.so
if [ $? != 0 ]; then
	echo "The SONAME of the lastest ARM lib is wrong!!!"
	exit 1
fi

~/android-ndk-r12b/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-readelf -d $1/x86/libViewRightVideoMarkClient.so | grep libViewRightVideoMarkClient.so
if [ $? != 0 ]; then
	echo "The SONAME of the lastest X86 lib is wrong!!!"
	exit 1
fi

cp $1/ARM/libViewRightVideoMarkClient.so $2/Thirdparty/Verimatrix/lib/Android/ARM/libViewRightVideoMarkClient.so
cp $1/x86/libViewRightVideoMarkClient.so $2/Thirdparty/Verimatrix/lib/Android/x86/libViewRightVideoMarkClient.so


echo "#ifdef __arm" > $2/Thirdparty/Verimatrix/inc/md5val.h
echo -n "    unsigned char g_check[] = { " >> $2/Thirdparty/Verimatrix/inc/md5val.h
calculate_md5 $2/Thirdparty/Verimatrix/lib/Android/ARM/libViewRightVideoMarkClient.so $2/Thirdparty/Verimatrix/inc/md5val.h
echo "#else" >> $2/Thirdparty/Verimatrix/inc/md5val.h
echo -n "    unsigned char g_check[] = { " >> $2/Thirdparty/Verimatrix/inc/md5val.h
calculate_md5 $2/Thirdparty/Verimatrix/lib/Android/x86/libViewRightVideoMarkClient.so $2/Thirdparty/Verimatrix/inc/md5val.h
echo "#endif" >> $2/Thirdparty/Verimatrix/inc/md5val.h

perl mv.pl android $2 $4


#calculate_md5 ~/Code/V3.22/Thirdparty/Verimatrix/lib/Android/ARM/libViewRightWebClient41.so