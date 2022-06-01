try {
      ObjectInputStream ois = new ObjectInputStream(new FileInputStream(storeFile));
      hm = (HashMap<String, byte[]>)ois.readObject();
      ois.close();

      Collection<byte[]> col = hm.values();
      col.remove(offlineKeySetId);

      ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(storeFile));
      oos.writeObject(hm);
      oos.flush();
      oos.close();

    }

try {
      ObjectInputStream ois = new ObjectInputStream(new FileInputStream(storeFile));
      hm = (HashMap<String, byte[]>)ois.readObject();
      ois.close();

      Parcel parcel = Parcel.obtain();
      parcel.setDataPosition(0);
      drmInitData.writeToParcel(parcel, 0);
      byte[] bytes = parcel.marshall();

      offlineKeySetId = hm.get(Base64.encodeToString(bytes, Base64.DEFAULT));
      hm.remove(Base64.encodeToString(bytes, Base64.DEFAULT));

      ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(storeFile));
      oos.writeObject(hm);
      oos.flush();
      oos.close();

      offlineLicenseHelper.releaseLicense(offlineKeySetId);

    }

try {
      ObjectInputStream ois = new ObjectInputStream(new FileInputStream(storeFile));
      hm = (HashMap<String, byte[]>)ois.readObject();
      ois.close();

    }

try {
      if (!storeFile.exists()){
        storeFile.createNewFile();

        HashMap<String, byte[]> hm = new HashMap<>();

        Parcel parcel = Parcel.obtain();
        parcel.setDataPosition(0);
        drmInitData.writeToParcel(parcel, 0);
        byte[] bytes = parcel.marshall();

        hm.put(Base64.encodeToString(bytes, Base64.DEFAULT), offlineKeySetId);

        ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(storeFile));
        oos.writeObject(hm);
        oos.flush();
        oos.close();
      } else {

        ObjectInputStream ois = new ObjectInputStream(new FileInputStream(storeFile));
        HashMap<String, byte[]> hm = (HashMap<String, byte[]>) ois.readObject();
        ois.close();

        Parcel parcel = Parcel.obtain();
        parcel.setDataPosition(0);
        drmInitData.writeToParcel(parcel, 0);
        byte[] bytes = parcel.marshall();

        hm.put(Base64.encodeToString(bytes, Base64.DEFAULT), offlineKeySetId);

        ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(storeFile));
        oos.writeObject(hm);
        oos.flush();
        oos.close();
      }

    }