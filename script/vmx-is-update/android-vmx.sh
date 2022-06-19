cd ~/vmx\ update
pwd

find . -type d -depth 1 -print0 | xargs -0 rm -rf

f=$(ls -t *.zip | head -1)

echo $f

unzip $f

version_index=$(echo $f | sed -nE "s/.*([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*$/\1/p")

echo $version_index

vmx_folder=$(find . -name "*$version_index*" -type d -depth 1)

cd $vmx_folder
pwd

unzip "*.zip"

arm64_v8a_folder=$(find . -name "*arm64-v8a*" -type d -depth 1)
armeabi_v7a_folder=$(find . -name "*armeabi-v7a*" -type d -depth 1)
x86_64_folder=$(find . -name "*x86_64*" -type d -depth 1)
x86_folder=$(find . -name "*x86[^_]*" -type d -depth 1)

echo $arm64_v8a_folder
echo $armeabi_v7a_folder
echo $x86_64_folder
echo $x86_folder

svn revert -R /Users/wcy/main/Thirdparty/Verimatrix
svn update /Users/wcy/main/Thirdparty/Verimatrix

cp $arm64_v8a_folder/libViewRightVideoMarkClient.so /Users/wcy/main/Thirdparty/Verimatrix/lib/Android/arm64/libViewRightVideoMarkClient.so
cp $armeabi_v7a_folder/libViewRightVideoMarkClient.so /Users/wcy/main/Thirdparty/Verimatrix/lib/Android/armeabi-v7a/libViewRightVideoMarkClient.so
cp $armeabi_v7a_folder/libViewRightVideoMarkClient.so /Users/wcy/main/Thirdparty/Verimatrix/lib/Android/armeabi/libViewRightVideoMarkClient.so
cp $x86_64_folder/libViewRightVideoMarkClient.so /Users/wcy/main/Thirdparty/Verimatrix/lib/Android/x86_64/libViewRightVideoMarkClient.so
cp $x86_folder/libViewRightVideoMarkClient.so /Users/wcy/main/Thirdparty/Verimatrix/lib/Android/x86/libViewRightVideoMarkClient.so

cp $arm64_v8a_folder/ViewRightWebClient.h /Users/wcy/main/Thirdparty/Verimatrix/inc/Android/ViewRightWebClient.h
cp $arm64_v8a_folder/ViewRightWebInterface.h /Users/wcy/main/Thirdparty/Verimatrix/inc/Android/ViewRightWebInterface.h

svn diff /Users/wcy/main/Thirdparty/Verimatrix/inc/Android/ViewRightWebClient.h /Users/wcy/main/Thirdparty/Verimatrix/inc/Android/ViewRightWebInterface.h

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

echo "#ifdef __armv6" > /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h
echo "    unsigned char g_check[] = { " >> /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h
calculate_md5 /Users/wcy/main/Thirdparty/Verimatrix/lib/Android/armeabi/libViewRightVideoMarkClient.so /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h
echo "#elif defined(__armv7)" >> /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h
echo "    unsigned char g_check[] = { " >> /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h
calculate_md5 /Users/wcy/main/Thirdparty/Verimatrix/lib/Android/armeabi-v7a/libViewRightVideoMarkClient.so /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h
echo "#elif defined(__armv8)" >> /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h
echo "    unsigned char g_check[] = { " >> /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h
calculate_md5 /Users/wcy/main/Thirdparty/Verimatrix/lib/Android/arm64/libViewRightVideoMarkClient.so /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h
echo "#elif defined(__x86)" >> /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h
echo "    unsigned char g_check[] = { " >> /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h
calculate_md5 /Users/wcy/main/Thirdparty/Verimatrix/lib/Android/x86/libViewRightVideoMarkClient.so /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h
echo "#elif defined(__x86_64)" >> /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h
echo "    unsigned char g_check[] = { " >> /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h
calculate_md5 /Users/wcy/main/Thirdparty/Verimatrix/lib/Android/x86_64/libViewRightVideoMarkClient.so /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h
echo "#endif" >> /Users/wcy/main/Thirdparty/Verimatrix/inc/md5val.h

# #ifdef __armv6
#     unsigned char g_check[] = { 0xfa, 0x85, 0x7e, 0x89, 0xac, 0xad, 0x34, 0x38, 0x71, 0xc5, 0xc8, 0xbf, 0x83, 0xfb, 0xca, 0x36 };
# #elif defined(__armv7)
#     unsigned char g_check[] = { 0xfa, 0x85, 0x7e, 0x89, 0xac, 0xad, 0x34, 0x38, 0x71, 0xc5, 0xc8, 0xbf, 0x83, 0xfb, 0xca, 0x36 };
# #elif defined(__armv8)
#     unsigned char g_check[] = { 0x2f, 0x90, 0x24, 0xaf, 0xbb, 0x53, 0x05, 0x39, 0x7d, 0xa9, 0x8d, 0xd5, 0x11, 0xa8, 0x8a, 0x0c };
# #elif defined(__x86)
#     unsigned char g_check[] = { 0x62, 0xd7, 0x4f, 0xe8, 0xba, 0x20, 0x46, 0x74, 0x16, 0x31, 0xe4, 0x78, 0x75, 0xaf, 0x7e, 0x70 };
# #elif defined(__x86_64)
#     unsigned char g_check[] = { 0x38, 0x5f, 0xa2, 0x61, 0x0b, 0x04, 0xf0, 0xb7, 0x41, 0x58, 0x02, 0xeb, 0x56, 0xac, 0x3b, 0x5d };
# #endif