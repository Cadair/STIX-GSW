

;+
; :Name:
;   STX_KM_COMPRESS
; :Description:
;    This function returns a compression of integer data into a 1 byte quasi-exponential expression for both positive
;    or negative values depending on the parameterization.
;    e.g.
;    IDL> print, stx_km_compress( lindgen(11)+246 )
;    78  78  79  79  79  79  79  79  79  79  80
;    IDL> print, stx_km_decompress( 79 )
;    252
;    IDL> print, stx_km_decompress( 79, /table )
;    248
;    For compression 248-255 all yield a compressed value of 79.  On decompression, 79 yields 252, midway from 248 to 255
;
;    From Gordon Hurford:
;    The the compression algorithm is applied to an integer value, V, to yield a compressed value, C, as follows:
;
;    1. If  V <   0,               set s=1 and set V = -V.
;
;    2. If  V <   2^(M+1),  set C = V and skip to step 6.
;
;    3. If  V >= 2^(M+1),  shift V right until 1’s (if any) appear only in LS M+1 bits
;
;    3. Exponent, e = number of shifts+ 1
;
;    4. Mantissa, m =  LS M bits of the shifted value.
;
;    5. Set C = m + 2^M * e
;
;    6. If S=1, set msb of C = s.
;
;    The algorithms that I (GH) remember were used on the Electron Isotope Spectrometers (E..C.Stone, PI) that flew on IMPs 7 and 8,
;    launched in 1972 and 1973?.
;
;
;
; :Params:
;    data - Input, must be integer type, to be compressed, see C above
;    k - number of bits for the exponent, default is 4
;    m - number of bits for the mantissa, default is 8-k
;    s - if set, then both positive and negative integers can be compressed, default is 0
;
; :Examples:
;   To create an interpolation table to use for compression or decompression:
;     decomp_table = stx_km_decompress( bindgen( 256 ), k, m, s, /table )
;     decomp_table = stx_km_decompress( bindgen( 256 ), 4, 4, 0, /table )
;    IDL> decomp_table = stx_km_decompress( bindgen( 256 ), 4, 3, 1, /table )
;    IDL> print, decomp_table
;    0           1           2           3           4           5           6           7           8           9          10          11          12          13          14          15
;    16          18          20          22          24          26          28          30          32          36          40          44          48          52          56          60
;    64          72          80          88          96         104         112         120         128         144         160         176         192         208         224         240
;    256         288         320         352         384         416         448         480         512         576         640         704         768         832         896         960
;    1024        1152        1280        1408        1536        1664        1792        1920        2048        2304        2560        2816        3072        3328        3584        3840
;    4096        4608        5120        5632        6144        6656        7168        7680        8192        9216       10240       11264       12288       13312       14336       15360
;    16384       18432       20480       22528       24576       26624       28672       30720       32768       36864       40960       45056       49152       53248       57344       61440
;    65536       73728       81920       90112       98304      106496      114688      122880      131072      147456      163840      180224      196608      212992      229376      245760
;    0          -1          -2          -3          -4          -5          -6          -7          -8          -9         -10         -11         -12         -13         -14         -15
;    -16         -18         -20         -22         -24         -26         -28         -30         -32         -36         -40         -44         -48         -52         -56         -60
;    -64         -72         -80         -88         -96        -104        -112        -120        -128        -144        -160        -176        -192        -208        -224        -240
;    -256        -288        -320        -352        -384        -416        -448        -480        -512        -576        -640        -704        -768        -832        -896        -960
;    -1024       -1152       -1280       -1408       -1536       -1664       -1792       -1920       -2048       -2304       -2560       -2816       -3072       -3328       -3584       -3840
;    -4096       -4608       -5120       -5632       -6144       -6656       -7168       -7680       -8192       -9216      -10240      -11264      -12288      -13312      -14336      -15360
;    -16384      -18432      -20480      -22528      -24576      -26624      -28672      -30720      -32768      -36864      -40960      -45056      -49152      -53248      -57344      -61440
;    -65536      -73728      -81920      -90112      -98304     -106496     -114688     -122880     -131072     -147456     -163840     -180224     -196608     -212992     -229376     -245760
;    IDL> decomp_table = stx_km_decompress( bindgen( 256 ), 5, 3, 0, /table )
;    IDL> print, decomp_table
;    0                     1                     2                     3                     4                     5                     6                     7                     8
;    9                    10                    11                    12                    13                    14                    15                    16                    18
;    20                    22                    24                    26                    28                    30                    32                    36                    40
;    44                    48                    52                    56                    60                    64                    72                    80                    88
;    96                   104                   112                   120                   128                   144                   160                   176                   192
;    208                   224                   240                   256                   288                   320                   352                   384                   416
;    448                   480                   512                   576                   640                   704                   768                   832                   896
;    960                  1024                  1152                  1280                  1408                  1536                  1664                  1792                  1920
;    2048                  2304                  2560                  2816                  3072                  3328                  3584                  3840                  4096
;    4608                  5120                  5632                  6144                  6656                  7168                  7680                  8192                  9216
;    10240                 11264                 12288                 13312                 14336                 15360                 16384                 18432                 20480
;    22528                 24576                 26624                 28672                 30720                 32768                 36864                 40960                 45056
;    49152                 53248                 57344                 61440                 65536                 73728                 81920                 90112                 98304
;    106496                114688                122880                131072                147456                163840                180224                196608                212992
;    229376                245760                262144                294912                327680                360448                393216                425984                458752
;    491520                524288                589824                655360                720896                786432                851968                917504                983040
;    1048576               1179648               1310720               1441792               1572864               1703936               1835008               1966080               2097152
;    2359296               2621440               2883584               3145728               3407872               3670016               3932160               4194304               4718592
;    5242880               5767168               6291456               6815744               7340032               7864320               8388608               9437184              10485760
;    11534336              12582912              13631488              14680064              15728640              16777216              18874368              20971520              23068672
;    25165824              27262976              29360128              31457280              33554432              37748736              41943040              46137344              50331648
;    54525952              58720256              62914560              67108864              75497472              83886080              92274688             100663296             109051904
;    117440512             125829120             134217728             150994944             167772160             184549376             201326592             218103808             234881024
;    251658240             268435456             301989888             335544320             369098752             402653184             436207616             469762048             503316480
;    536870912             603979776             671088640             738197504             805306368             872415232             939524096            1006632960            1073741824
;    1207959552            1342177280            1476395008            1610612736            1744830464            1879048192            2013265920            2147483648            2415919104
;    2684354560            2952790016            3221225472            3489660928            3758096384            4026531840            4294967296            4831838208            5368709120
;    5905580032            6442450944            6979321856            7516192768            8053063680            8589934592            9663676416           10737418240           11811160064
;    12884901888           13958643712           15032385536           16106127360
;    IDL> decomp_table = stx_km_decompress( bindgen( 256 ), 4, 4, 0, /table )
;    IDL> print, decomp_table
;    0           1           2           3           4           5           6           7           8           9          10          11          12          13          14          15
;    16          17          18          19          20          21          22          23          24          25          26          27          28          29          30          31
;    32          34          36          38          40          42          44          46          48          50          52          54          56          58          60          62
;    64          68          72          76          80          84          88          92          96         100         104         108         112         116         120         124
;    128         136         144         152         160         168         176         184         192         200         208         216         224         232         240         248
;    256         272         288         304         320         336         352         368         384         400         416         432         448         464         480         496
;    512         544         576         608         640         672         704         736         768         800         832         864         896         928         960         992
;    1024        1088        1152        1216        1280        1344        1408        1472        1536        1600        1664        1728        1792        1856        1920        1984
;    2048        2176        2304        2432        2560        2688        2816        2944        3072        3200        3328        3456        3584        3712        3840        3968
;    4096        4352        4608        4864        5120        5376        5632        5888        6144        6400        6656        6912        7168        7424        7680        7936
;    8192        8704        9216        9728       10240       10752       11264       11776       12288       12800       13312       13824       14336       14848       15360       15872
;    16384       17408       18432       19456       20480       21504       22528       23552       24576       25600       26624       27648       28672       29696       30720       31744
;    32768       34816       36864       38912       40960       43008       45056       47104       49152       51200       53248       55296       57344       59392       61440       63488
;    65536       69632       73728       77824       81920       86016       90112       94208       98304      102400      106496      110592      114688      118784      122880      126976
;    131072      139264      147456      155648      163840      172032      180224      188416      196608      204800      212992      221184      229376      237568      245760      253952
;    262144      278528      294912      311296      327680      344064      360448      376832      393216      409600      425984      442368      458752      475136      491520      507904;
; :Keywords:
;    error - returns 0 if successful, 1 for early termination
;    ABS_RANGE - absolute_range for values of k, m, s
;    RANGE_ERR - if set, data violates abs_range and returns 0!
;    TYPE_ERR  - K must be integer type, returns a type_err of 1 and complains on non-integer input
;
; :Author: richard.schwartz@nasa.gov
;
; :History: 11-may-2015, initial version
; 4-oct-2016, RAS added range checking, ABS_RANGE, RANGE_ERR,
; 8-dec-2016, RAS, fixed computation for single negative numbers, "changed to ge 1 from gt 1 ras, 8-dec-2016"
; 13-mar-2017, RAS, added type_err for non-integer input
; 21-mar-2017, NH, added K M S undefined warning. All KMS values should be definded in some configuration files and nor rely on defaults  
;-
function stx_km_compress, data, k, m, s, abs_range = abs_range, range_err = range_err,  type_err=type_err, error = error

  error = 1
  range_err = 0
  type_err  = value_locate( [1,4,12], size(/type, data) ) mod 2 ne 0 ;integers return 0
  if type_err then begin
    message, /info, 'Input must be integer type'
    help, data
    type_err = 1
    return, 0
  endif

  if ~isa(k) || ~isa(m) || ~isa(s) then begin
    message, /info, 'K ,M or S is undefined using default instead!'
  endif


  default, k, 4
  default, m, 8 - k
  default, s, 0
  kms = k + m + s
  if kms gt 8 then begin
    print, 'k, m, s must total le 8 to be valid '
    print, 'Their total is ', kms
    return, -1 ; error condition
  endif
  ;  max_value = 2LL^(2^(K-s)-2)  * (2LL^(M+1) -1)
  ;  abs_range = s eq 0 ? [0, max_value] : [-1, 1] * max_value
  abs_range = stx_km_compress_range( k, m, s )
  mmdata    = minmax( data )
  range_err = mmdata[0] lt abs_range[0] || mmdata[1] gt abs_range[1]

  if range_err then begin
    message, /info, 'Input valid range exceeded'
    print, 'MinMax( data ) is ',mmdata
    print, 'ABS_RANGE for k, '+strtrim(k,2)+', and m, '+strtrim(m,2)+', and s, '+strtrim(s,2)+' is '+strtrim( abs_range, 2)
    range_err = 1
    return, 0
  endif
  adata = long(abs( data )) ;only valid for integer data types
  q     = where( data lt 0, nq )
  out = byte(adata)

  z   = where( adata ge 2^(m+1), nz)
  if nz eq 0 then begin
    error = 0
    return, out
  endif
  if nz ge 1 then begin
    kv = (fix( alog(adata[z]>1) / alog(2) + 0.001 - m ) > 0)
    mv = ( adata[z] / 2LL^kv ) and ( 2^(m) -1 )
    out[z] =  byte( ishft( kv+1, m ) or mv )
  endif
  if s && (nq ge 1) then out[q] +=128 ;fixed ge 1 from gt 1 ras, 8-dec-2016
  error = 0
  return, out
end
