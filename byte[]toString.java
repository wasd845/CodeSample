byte[] key = keyStatus.getKeyId();
StringBuilder builder = new StringBuilder();
String hexdigits = "0123456789abcdef";
for (int i = 0; i < key.length; i++) {
  builder.append(hexdigits.charAt((key[i] & 0xf0) >> 4));
  builder.append(hexdigits.charAt(key[i] & 0x0f));
}

Log.i(builder.toString());