Parcel parcel = Parcel.obtain();
parcel.setDataPosition(0);
drmInitData.writeToParcel(parcel, 0);
byte[] bytes = parcel.marshall();