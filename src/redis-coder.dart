class RedisCoder {
  List encode(List args) {
    List<int> buffer = new List<int>();

    // Encode the number of arguments
    buffer.addAll(encodeUtf8("*${args.length}\r\n"));

    // Encode each argument
    args.forEach((arg) {
      buffer.addAll(encodeUtf8("\$${arg.length}\r\n"));
      buffer.addAll(arg);
      buffer.addAll(encodeUtf8("\r\n"));
    });
    return buffer;
  }

  List decode(List<int> bytes) {
    List message = new List();
    List<int> arg_buffer = new List<int>();
    int lastRead, i;

    for (i = 0; i < bytes.length; i++) {
      if (lastRead == 13 && bytes[i] == 10) {
        arg_buffer.removeLast();

        // We've just read a line
        if (arg_buffer[0] == 42) {
          // We ignore the number of args
        } else if (arg_buffer[0] == 36) {
          // We ignore the size of the current arg
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