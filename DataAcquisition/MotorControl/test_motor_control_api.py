import MCutils as mc

  
def runProg(ser):
    while True:
      ser.write(b'1');
      while ser.in_waiting==0:
        pass
    
      msg = ser.readline().decode("utf-8")
      if (msg == 'Done!\r\n'):
        break
      else:
        print(msg)
        
    print("Program ended successfully")
            
def main():
    try:
        ser = mc.establishConnection()
        mc.uploadConfig(ser)
        mc.sanityCheck(ser)
        runProg(ser)
    except Exception as e:
        print(e)
    
     
if __name__ == "__main__":
    main()