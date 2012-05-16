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

  static List decode(List<int> bytes) {
    List message = new List();
    List<int> arg_buffer = new List<int>();
    int lastRead, i, num_of_args, size_of_current_arg;

    for (i = 0; i < bytes.length; i++) {
      if (lastRead == 13 && bytes[i] == 10) {
        arg_buffer.removeLast();

        // We've just read a line
        if (arg_buffer[0] == 42) {
          num_of_args = arg_buffer[1];
        } else if (arg_buffer[0] == 36) {
          size_of_current_arg = arg_buffer[1];
        } else {
          message.add(arg_buffer);    
        }
        arg_buffer = new List();
        lastRead = null;
      } else {
        arg_buffer.add(bytes[i]);
        lastRead = bytes[i];
      }
    }
    
    return message;
  }
}