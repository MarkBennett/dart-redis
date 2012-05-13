class RedisCoder {
  static List encode(List args) {
    StringBuffer buffer = new StringBuffer();

    // Encode the number of arguments
    buffer.add("*${args.length}\r\n");

    // Encode each argument
    args.forEach((arg) {
      List encoded_arg = encodeUtf8(arg);
      buffer.add("\$${encoded_arg.length}\r\n");
      buffer.add("$arg\r\n");
    });
    return encodeUtf8(buffer.toString());
  }
}