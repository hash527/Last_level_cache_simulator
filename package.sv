package operations;

typedef enum [1:0]{READ, WRITE, INVALIDATE, RWIM} Bus_Ops;
typedef enum [1:0]{NOHIT, HIT, HITM} Snoop_Results;
typedef enum [1:0]{GETLINE, SENDLINE, INVALIDATELINE, EVICTLINE} L2_to_L1;

endpackage

