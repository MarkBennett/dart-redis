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

  // SPECIAL BYTES
  // ASCII values from http://en.wikipedia.org/wiki/File:ASCII_Code_Chart.svg
  int CR_BYTE       = 13,
      LF_BYTE       = 10,
      STAR_BYTE     = 42 ,
      DOLLAR_BYTE   = 36,
      PLUS_BYTE     = 43;
      
  // STATES
  int INITIAL                       = 0,
      READING_NUM_OF_ARGS           = 1,
      READING_NUM_OF_BYTES_IN_ARG   = 2,
      READING_ARG                   = 3,
      READING_STATUS                = 4,
      COMPLETE                      = 5;

  Future<List> readMessage(InputStream stream) {
    Completer on_message = new Completer();
    List<int> args = [];
    List<int> buffer = new List<int>(100);
    List<int> line_buffer = [];
    int state = INITIAL;
    int num_of_args = 1;
    int num_of_bytes_in_arg = 0;
    
    stream.onData = () {
      print("on Data!");
      while (state != COMPLETE) {
        buffer = stream.read(100);
        if (buffer != null) {
          buffer.forEach((elem) {
            print("state = $state, elem = $elem");
            switch (state) {
              case (INITIAL):
                switch (elem) {
                  case STAR_BYTE:
                    state = READING_NUM_OF_ARGS;
                    line_buffer = [];
                    break;
                  case DOLLAR_BYTE:
                    state = READING_NUM_OF_BYTES_IN_ARG;
                    line_buffer = [];
                    break;
                  case PLUS_BYTE:
                    state = READING_STATUS;
                    line_buffer = [];
                    break; 
                  default:
                    throw "Unexpected byte read: $elem";
                    break;
                }
                break;
              case (READING_NUM_OF_ARGS):
                print("Reading number of args");
                if (elem == LF_BYTE && line_buffer.last() == CR_BYTE) {
                  // We just finished reading the number of args
                  line_buffer.removeLast();
                  num_of_args = Math.parseInt(decodeUtf8(line_buffer));
                  print("Reading $num_of_args args");
                  state = INITIAL;
                } else {
                  print("Read $elem");
                  line_buffer.add(elem);
                }
                break;
              case (READING_NUM_OF_BYTES_IN_ARG):
                if (elem == LF_BYTE && line_buffer.last() == CR_BYTE) {
                  // We just finished reading the number of bytes in the arg
                  line_buffer.removeLast();
                  num_of_bytes_in_arg = Math.parseInt(decodeUtf8(line_buffer));
                  print("Read number of bytes in arg = $num_of_bytes_in_arg");
                  state = READING_ARG;
                } else {
                  line_buffer.add(elem);
                }
                break;
              case (READING_ARG):
                if (elem == LF_BYTE && line_buffer.last() == CR_BYTE) {
                  // We just finished reading the arg
                  line_buffer.removeLast();
                  args.add(line_buffer);
                  num_of_args--;

                  if (num_of_args == 0) {
                    // This is the last arg
                    state = COMPLETE;
                    print("Read args = $args");
                    on_message.complete(args);
                  } else {
                    // More args to go!
                    state = INITIAL;
                  }
                } else {
                  line_buffer.add(elem);
                }
                break;
              case (READING_STATUS):
                print("Reading status, elem = $elem");
                if (elem == LF_BYTE && line_buffer.last() == CR_BYTE) {
                  // We just read the status
                  line_buffer.removeLast();
                  print("read status!");
                  state = COMPLETE;
                  on_message.complete([decodeUtf8(line_buffer)]);
                } else {
                  line_buffer.add(elem);
                }
                break;
              case (COMPLETE):
                break;
            }
          });
        }
      }
    };

    return on_message.future;
  }
}
