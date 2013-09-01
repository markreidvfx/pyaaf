import struct

def parse_chunk(id,data):
    
    """
    a chunks seem to always start with the word "Avid"
    
    [   Avid  ][       ???     ][  string length  ][ type of object ][              ]
    [ char[4] ][ unsigned short][  unsigned short ][     char []    ][ object data .]
    
    if the id[0] == 101 it doesn't seem to follow this pattern
    [  Avid   ][      ???      ][ identification data???]
    [char[4]  ][ unsigned short][     char[8]          ]
    
    """
    
    
    d = {}
    d['id'] = id
    d['data'] = data
    
    if id[1] == 101:
        avid,value1, text = struct.unpack(">4sH8s",data)
        d['type'] = "Title"
        d['text'] = text
        
    else:
        avid,value1,str_length = struct.unpack(">4sHH",data[:8])
        
        #strings apear to be null terminated on TitleRectangle the length seems to include the null
        #strip it of if its there
        item_type = struct.unpack(">8x%is" % str_length,data[:8 + str_length])[0].rstrip("\0")

        d['type'] = item_type
        if item_type == "TitleText":
            
            #the byte offset 224 is the lenght of the text string
            #the string also appears to be null terminated...
            text_length = struct.unpack(">224xH",data[:226])[0]
            
            text = struct.unpack(">226x%is" % text_length,data[:226 + text_length])[0]
                        
            d['text'] = text

            
    return d

    
def first_byte(data):
    """
    seek until you find a an int with a value of 161, 101 and string name AVID
    """
    for i in xrange(len(data)-10):

        key1,key2,length,avid  = struct.unpack(">HHH4s",data[i:i+10])
        if key1 == 161 and key2 in (100,101,102,104) and avid == "AVID":
            return i

    raise ValueError("Invalid Data")

def pct_parser(data):
    """
    parses .pct or .pict files saved with the Avid Title Tool. Currently only 
    extracts the Text strings, from TitleText objects.
    
    To use AvidBagOfBits from a Title_2 OperationDefinition convert the list 
    to a unsigned char array using python array module
    example:
        data  = array.array("B",AvidBagOfBits)
        
    return a list of dictionaries
    """
    
    i = first_byte(data)
    chunks = []
    
    #print find_first_byte(data)
    #return
    while True:
        
        #the data is broken into chunks
        #looks like KLV data of some kind and is big-endian.
        #not exactly sure what the values mean but this seams to work..
        #[   key1       ][    key2      ][ data length  ][  data   ]
        #[unsigned short][unsigned short][unsigned short][  data.. ]
        
        key1 = struct.unpack(">H",data[i:i+2])[0]
        
        #if the first key is 225 its the end of the file
        #if the first key is 30 its the end of the data in a pict file
        if key1 == 255 or key1 == 30:
            break
        
        
        #key 2 seems to have something to do with type of data 
        #most of the time it seems to be 100 or 101
        
        key2 = struct.unpack(">H",data[i+2:i+4])[0]
        
        #the 3rd variable is the length of the data chunk
        length = struct.unpack(">H",data[i+4:i+6])[0]

        offset = length + 6
        data_chunk = data[i+6:i+offset]
        

        if key2 in (101,100):
            chunks.append(parse_chunk((key1,key2),data_chunk))
            
        elif key2 in (102,104):
            end = first_byte(data[i+6:])
            marque_data = data[i+6 + 4:i+end+6]
            chunks.append({"id":(key1,key2),
                           "type":"MarqueTitle",
                           'data':str(marque_data)})
            
            break
        
        else:
            raise ValueError("Unkown data type %i" % key2)
        
        #move to the next chunk
        i += offset

    return chunks


if __name__ == "__main__":
    from pprint import pprint
    from optparse import OptionParser
    
    parser = OptionParser()
    parser.add_option('-v', '--verbose',action="store_true", default=False)
    (options, args) = parser.parse_args()
    
    if args:
        test_file = args[0]
    else:
        parser.error("No Args")
        
    def chunks(l, n):
        """ Yield successive n-sized chunks from l.
        """
        for i in xrange(0, len(l), n):
            yield l[i:i+n]
    
            
    f = open(test_file)
    s = f.read()
    f.close()
    
    length =  struct.unpack(">512x H", s[:512 + 2])[0]
    
    d = pct_parser(s)
    
    
    for pct_item in d:
         
        print "%s:" % pct_item['type']
         
        for key,value in sorted(pct_item.items()):
            if key == "data":
                if options.verbose:
                    print '   Data:'
                    for s in chunks(repr(value)[1:-1], 80):
                        print "    ", s
            elif key in ('type'):
                pass
            else:
                print "   %s = %s" % (key, str(value)) 

