﻿601,100
602,"}bedrock.hier.import"
562,"CHARACTERDELIMITED"
586,"D:\TM1Models\Bedrock.v4\Log\Currency Currency 2_Export.csv"
585,"D:\TM1Models\Bedrock.v4\Log\Currency Currency 2_Export.csv"
564,
565,"pQlZjiR6LqmVY>OyazWUEh0\t]ZcpL4v5z]thla17tKwKRK>?yB7IHiV:=_q]z3A9NCaoRx?6y1u0;M0gwNJ=X?0vvBG0`wdF<Xj<KSgP0AC5oOmToB;660q?zT9\UM4MSl8T`06c?0d9EOawh@TzVNhIh9G2y2iCpimR4_cRc>sdOWi\9IsYYZ3a_<Q:4_7?Fu\_ALk"
559,1
928,0
593,
594,
595,
597,
598,
596,
800,
801,
566,0
567,","
588,"."
589,","
568,""""
570,
571,
569,0
592,0
599,1000
560,8
pLogOutput
pDim
pHier
pSrcDir
pSrcFile
pDelim
pQuote
pLegacy
561,8
1
2
2
2
2
2
2
1
590,8
pLogOutput,0
pDim,""
pHier,""
pSrcDir,""
pSrcFile,""
pDelim,","
pQuote,""""
pLegacy,0
637,8
pLogOutput,"Optional: write parameters and action summary to server message log (Boolean True = 1)"
pDim,"Required: Dimension"
pHier,"Optional: Target Hierarchy (defaults to dimension name if blank)"
pSrcDir,"Optional: Source Directory Path (defaults to Error File Directory)"
pSrcFile,"Optional: Source File Name (defaults to 'Dimension Hierarchy _Export.csv' if blank)"
pDelim,"Optional: AsciiOutput delimiter character (Default=comma, exactly 3 digits = ASCII code)"
pQuote,"Optional: AsciiOutput quote character (Accepts empty quote, exactly 3 digits = ASCII code)"
pLegacy,"Required: Boolean 1 = Legacy format"
577,6
V1
V2
V3
V4
V5
V6
578,6
2
2
2
2
2
2
579,6
1
2
3
4
5
6
580,6
0
0
0
0
0
0
581,6
0
0
0
0
0
0
582,6
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
603,0
572,224
#Region CallThisProcess
# A snippet of code provided as an example how to call this process should the developer be working on a system without access to an editor with auto-complete.
If( 1 = 0 );
    ExecuteProcess( '}bedrock.hier.import', 'pLogOutput', pLogOutput,
    	'pDim', '', 'pHier', '',
    	'pSrcDir', '', 'pSrcFile', '',
    	'pDelim', ',', 'pQuote', '"',
    	'pLegacy', 0
	);
EndIf;
#EndRegion CallThisProcess

#****Begin: Generated Statements***
#****End: Generated Statements****

################################################################################################# 
##~~Join the bedrock TM1 community on GitHub https://github.com/cubewise-code/bedrock Ver 4.0~~##
################################################################################################# 

#Region @DOC
# Description:
# This process will import Dimension elements into a specified Hierarchy from a File. The process
# is able to read a file generated by `}bedrock.hier.export`.
# __Format of the file:__  
# - 1st line: File metadata contains summary information about the dimension, hierarchy, number of
#   elements and date/time when file was generated.
# - 2nd line: Source dimension and hierarchy.
# - 3rd line: Dimension sort order.
# - 4th and 5th line: Reserved for future development.
# - 6th line: Header for elements export.
# - 7th line and forth: Elements export data.

# Use case:
# 1. Restore a dimension from a backup.
# 2. Quick replication of a large dimension.

# Note:
# Valid dimension name (pDim) and legacy export format (pLegacy) are mandatory otherwise the
# process will abort.
# If needed, custom delimiter might be used by specifying parameter pDelim value as either exactly one
# character or as a 3-digit (decimal) ASCII code. For example to use TAB as a delimiter, use 009.

# Caution: Process was redesigned in Bedrock4 but is able to process dimension extracts from prior
# versions of Bedrock in legacy mode (pLegacy = 1).
#EndRegion @DOC

# This process will Create Dimension hierarchy from File.
### Global Variables
StringGlobalVariable('sProcessReturnCode');
NumericGlobalVariable('nProcessReturnCode');
nProcessReturnCode= 0;

### Constants ###
cThisProcName   = GetProcessName();
cUserName       = TM1User();
cTimeStamp      = TimSt( Now, '\Y\m\d\h\i\s' );
cRandomInt      = NumberToString( INT( RAND( ) * 1000 ));
cTempSub        = cThisProcName |'_'| cTimeStamp |'_'| cRandomInt;
cMsgErrorLevel  = 'ERROR';
cMsgErrorContent= 'Process:%cThisProcName% ErrorMsg:%sMessage%';
cLogInfo        = 'Process:%cThisProcName% run with parameters pDim:%pDim%, pHier:%pHier%, pSrcDir:%pSrcDir%, pSrcFile:%pSrcFile%, pDelim:%pDelim%, pQuote:%pQuote%, pLegacy:%pLegacy%.';
cLenASCIICode = 3;

pDelim  = TRIM(pDelim);

## LogOutput parameters
IF( pLogoutput = 1 );
    LogOutput('INFO', Expand( cLogInfo ) );   
ENDIF;

nMetaCount = 0;
nDataCount = 0;

### Validate Parameters ###
nErrors = 0;

If( Scan( ':', pDim ) > 0 & pHier @= '' );
    # A hierarchy has been passed as dimension. Handle the input error by splitting dim:hier into dimension & hierarchy
    pHier       = SubSt( pDim, Scan( ':', pDim ) + 1, Long( pDim ) );
    pDim        = SubSt( pDim, 1, Scan( ':', pDim ) - 1 );
EndIf;

# Validate dimension
If( Trim( pDim ) @= '' );
    nErrors = 1;
    sMessage = 'No dimension specified.';
    LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
ElseIf( DimensionExists( pDim ) = 0 );
    sMessage = 'Dimension: ' | pDim | ' does not exist and will be created.';
    LogOutput( 'INFO', Expand( cMsgErrorContent ) );
EndIf;

# Validate Hierarchy
sHier       = Trim( pHier );
If( sHier @= '' );
    sHier     = pDim;
ElseIf( sHier @= 'Leaves' );
    nErrors   = 1;
    sMessage  = 'Invalid  Hierarchy: ' | pDim |':'|sHier;
    LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
EndIf;

## Validate source dir
If( Trim( pSrcDir ) @= '' );
    pSrcDir     = GetProcessErrorFileDirectory;
    sMessage    = 'Source folder defaulted to error file directory.';
    LogOutput( 'INFO', Expand( cMsgErrorContent ) );
ElseIf( FileExists( pSrcDir ) = 0 );
    nErrors     = 1;
    sMessage    = 'Invalid source path specified. Folder does not exist.';
    LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
ElseIf( SubSt( pSrcDir, Long( pSrcDir ), 1 ) @<> '\' );
    pSrcDir     = pSrcDir | '\';
EndIf;

# Validate export filename
If( pSrcFile @= '' );
  pSrcFile      = pDim | If( pLegacy = 1,'',' '|sHier ) | '_Export.csv';
ElseIf( Scan( '.', pSrcFile ) = 0 );
    # No file extension specified
    pSrcFile    = pSrcFile | '.csv';
EndIf;

# Construct full export filename including path
sFilename       = pSrcDir | pSrcFile;
sAttrDimName    = '}ElementAttributes_' | pDim ;

If( FileExists( sFilename ) = 0 );
    nErrors     = 1;
    sMessage    = 'Invalid path\file specified. It does not exist.';
    LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
EndIf;

# Validate file delimiter & quote character
If( pDelim @= '' );
    pDelim = ',';
Else;
    # If length of pDelim is exactly 3 chars and each of them is decimal digit, then the pDelim is entered as ASCII code
    nValid = 0;
    If ( LONG(pDelim) = cLenASCIICode );
      nChar = 1;
      While ( nChar <= cLenASCIICode );
        If( CODE( pDelim, nChar )>=CODE( '0', 1 ) & CODE( pDelim, nChar )<=CODE( '9', 1 ) );
          nValid = 1;
        Else;
          nValid = 0;
        EndIf;
        nChar = nChar + 1;
      End;
    EndIf;
    If ( nValid<>0 );
      pDelim=CHAR(StringToNumber( pDelim ));
    Else;
      pDelim = SubSt( Trim( pDelim ), 1, 1 );
    EndIf;
EndIf;
If( pQuote @= '' );
    ## Use no quote character 
Else;
    # If length of pQuote is exactly 3 chars and each of them is decimal digit, then the pQuote is entered as ASCII code
    nValid = 0;
    If ( LONG(pQuote) = cLenASCIICode );
      nChar = 1;
      While ( nChar <= cLenASCIICode );
        If( CODE( pQuote, nChar ) >= CODE( '0', 1 ) & CODE( pQuote, nChar ) <= CODE( '9', 1 ) );
          nValid = 1;
        Else;
          nValid = 0;
        EndIf;
        nChar = nChar + 1;
      End;
    EndIf;
    If ( nValid<>0 );
      pQuote=CHAR(StringToNumber( pQuote ));
    Else;
      pQuote = SubSt( Trim( pQuote ), 1, 1 );
    EndIf;
EndIf;

### Check for errors before continuing
If( nErrors <> 0 );
  ProcessBreak;
EndIf;

### Prepare target dimension ###
If( HierarchyExists( pDim, sHier ) = 1 );
    ExecuteProcess('}bedrock.hier.unwind',
	'pLogOutput',pLogOutput,
	'pDim',pDim,
	'pHier',sHier,
	'pConsol','',
	'pRecursive',1);
Else;
    ExecuteProcess('}bedrock.hier.create',
	'pLogOutput',pLogOutput,
	'pDim',pDim,
	'pHier',sHier);
EndIf;

If( nErrors = 0 );
    If( HierarchyExists( pDim, pHier ) = 1 );
        sMessage = 'Dimension unwound: ' | pDim|':'|sHier;
    Else;
        sMessage = 'Dimension created: ' | pDim|':'|sHier;
    EndIf;
Else;
    ProcessBreak;
EndIf;

### CONSTANTS ###
sAttrDimName    = '}ElementAttributes_' | pDim ;
cCubeS1         = '}DimensionProperties';

#Processbreak;

### Assign Datasource ###
DataSourceType          = 'CHARACTERDELIMITED';
DatasourceNameForServer = sFilename;
DatasourceNameForClient = sFilename;
DatasourceAsciiDelimiter= pDelim;
DatasourceAsciiQuoteCharacter = pQuote;


##### End Prolog #####
573,48

#****Begin: Generated Statements***
#****End: Generated Statements****

################################################################################################# 
##~~Join the bedrock TM1 community on GitHub https://github.com/cubewise-code/bedrock Ver 4.0~~##
################################################################################################# 

### Check for errors before continuing
If( nErrors <> 0 );
  ProcessBreak;
EndIf;

If( pDim @= sHier);
    sDim = pDim;
Else;
    sDim = pDim|':'|sHier;
Endif;

### Metadata Count
nMetaCount = nMetaCount + 1;

sVar2 = Subst( v2 , Scan( '-' , v2 )+1 , 99 );
sVar3 = Subst( v3 , Scan( '-' , v3 )+1 , 99 );
sVar4 = Subst( v4 , Scan( '-' , v4 )+1 , 99 );
sVar5 = Subst( v5 , Scan( '-' , v5 )+1 , 99 );

### Build dimension
IF( V1 @= 'A' );
    ATTRINSERT( pDim, '', sVar2 , SUBST( sVar3, 2, 1 ) );
    
ELSEIF(V1 @= 'E' );
    HierarchyElementInsert( pDim, sHier, '', sVar2 , sVar3 );
    IF( pLogOutput = 1 );
        sMessage    = Expand('Inserted element %sVar2% into %sDim% as type %sVar3%.');
        LogOutput( 'INFO', Expand( cMsgErrorContent ) );  
    ENDIF;
ELSEIF(V1 @= 'P' );
    HierarchyElementInsert( pDim, sHier, '', sVar3 , sVar4 );
    HierarchyElementComponentAdd( pDim, sHier, sVar3 , sVar2 , StringToNumber( sVar5 ) );
    IF( pLogOutput = 1 );
        sMessage    = Expand('Inserted parent %sVar3% into %sDim% as type %sVar4%. Then added %sVar2% to %sVar3% with a weight of %sVar5%.');
        sMessage    = Expand('Added %sVar2% to %sVar3% with a weight of %sVar5%.');
        LogOutput( 'INFO', Expand( cMsgErrorContent ) );  
    ENDIF;

ENDIF;

574,58

#****Begin: Generated Statements***
#****End: Generated Statements****

################################################################################################# 
##~~Join the bedrock TM1 community on GitHub https://github.com/cubewise-code/bedrock Ver 4.0~~##
################################################################################################# 

### Check for errors before continuing
If( nErrors <> 0 );
  ProcessBreak;
EndIf;

### Data Count
nDataCount = nDataCount + 1;

sVar1 = v1;
sVar2 = Subst( v2 , Scan( '-' , v2 )+1 , 99 );
sVar3 = Subst( v3 , Scan( '-' , v3 )+1 , 99 );
sVar4 = Subst( v4 , Scan( '-' , v4 )+1 , 99 );
sVar5 = Subst( v5 , Scan( '-' , v5 )+1 , 99 );

If( pDim @= sHier);
    sDim = pDim;
Else;
    sDim = pDim|':'|sHier;
Endif;

## Set Dimension Sort 
IF( v1 @= 'Sort parameters :' );
    CELLPUTS( sVar2, cCubeS1 , sDim, 'SORTELEMENTSTYPE' );
    CELLPUTS( sVar3, cCubeS1 , sDim, 'SORTCOMPONENTSTYPE' );
    CELLPUTS( sVar4, cCubeS1 , sDim, 'SORTELEMENTSSENSE' );
    CELLPUTS( sVar5, cCubeS1 , sDim, 'SORTCOMPONENTSSENSE' );
ElseIF( nDataCount = 3 );
    CELLPUTS( sVar1, cCubeS1 , sDim, 'SORTELEMENTSTYPE' );
    CELLPUTS( sVar2, cCubeS1 , sDim, 'SORTCOMPONENTSTYPE' );
    CELLPUTS( sVar3, cCubeS1 , sDim, 'SORTELEMENTSSENSE' );
    CELLPUTS( sVar4, cCubeS1 , sDim, 'SORTCOMPONENTSSENSE' );
ENDIF;

### Load Attributes ###
IF( V1 @= 'V' );
    sAttrType =DTYPE( sAttrDimName , sVar3 );
    IF ( pDim @<> sHier );
        IF( sAttrType @= 'AN' );
            ElementAttrPUTN( StringToNumber( sVar4 ), pDim, sHier, sVar2, sVar3 );
        ELSE;
            ElementATTRPUTS( sVar4, pDim, sHier, sVar2, sVar3 );
        ENDIF;
    ELSE;
        IF( sAttrType @= 'AN' );
            AttrPUTN( StringToNumber( sVar4 ), pDim, sVar2, sVar3 );
        ELSE;
            ATTRPUTS( sVar4, pDim, sVar2, sVar3 );
        ENDIF;        
    ENDIF;
ENDIF;
575,26

#****Begin: Generated Statements***
#****End: Generated Statements****

################################################################################################# 
##~~Join the bedrock TM1 community on GitHub https://github.com/cubewise-code/bedrock Ver 4.0~~##
################################################################################################# 

### If errors occurred terminate process with a major error status ###
If( nErrors > 0 );
    sMessage = 'the process incurred at least 1 major error and consequently aborted. Please see above lines in this file for more details.';
    nProcessReturnCode = 0;
    LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
    sProcessReturnCode = Expand( '%sProcessReturnCode% Process:%cThisProcName% aborted. Check tm1server.log for details.' );
    ProcessError;
EndIf;

### Return Code
sProcessAction      = Expand( 'Process:%cThisProcName% successfully imported data from %sFileName% and updated the %pDim%:%pHier% dimension:hierarchy.' );
sProcessReturnCode  = Expand( '%sProcessReturnCode% %sProcessAction%' );
nProcessReturnCode  = 1;
If ( pLogoutput = 1 );
    LogOutput('INFO', Expand( sProcessAction ) );   
EndIf;

### End Epilog ###
576,
930,0
638,1
804,0
1217,1
900,
901,
902,
938,0
937,
936,
935,
934,
932,0
933,0
903,
906,
929,
907,
908,
904,0
905,0
909,0
911,
912,
913,
914,
915,
916,
917,0
918,1
919,0
920,0
921,""
922,""
923,0
924,""
925,""
926,""
927,""
