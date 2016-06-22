tree grammar MaslFormat;

options
{
  tokenVocab=MaslParser;
  ASTLabelType=CommonTree;
}

@header
{
import java.io.*;
import java.util.Collections;
}

@annotations
{
@SuppressWarnings("all")
}

@members
{
// private fields
private PrintStream out;
private int indent;
private boolean sort;
private boolean reorder;

private static final String _ASSIGN         = ":=";
private static final String _CANNOT_HAPPEN  = "Cannot_Happen";
private static final String _COLON          = ":";
private static final String _COMMA          = ",";
private static final String _DEFERRED       = "deferred";
private static final String _DOMAIN         = "domain";
private static final String _DOT            = ".";
private static final String _END            = "end";
private static final String _ENUM           = "enum";
private static final String _EVENT          = "event";
private static final String _EXCEPTION      = "exception";
private static final String _GOES_TO        = "=>";
private static final String _IDENTIFIER     = "identifier";
private static final String _IGNORE         = "Ignore";
private static final String _INSTANCE       = "instance";
private static final String _IS             = "is";
private static final String _IS_A           = "is_a";
private static final String _LPAREN         = "(";
private static final String _NEWLINE        = "\n";
private static final String _NON_EXISTENT   = "Non_Existent";
private static final String _OBJECT         = "object";
private static final String _PRAGMA         = "pragma";
private static final String _PROJECT        = "project";
private static final String _REFERENTIAL    = "referential";
private static final String _RELATIONSHIP   = "relationship";
private static final String _RETURN         = "return";
private static final String _RPAREN         = ")";
private static final String _SCOPE          = "::";
private static final String _SEMI           = ";";
private static final String _SPACE          = " ";
private static final String _STATE          = "state";
private static final String _STRUCTURE      = "structure";
private static final String _TERMINATOR     = "terminator";
private static final String _TRANSITION     = "transition";
private static final String _TYPE           = "type";
private static final String _USING          = "using";

// tab defaults to 2 spaces, but can be set by the user
private static String _TAB                  = "  ";

// initilization
public void init() {
    out = System.out;
    indent = 0;
    sort = false;
    reorder = false;
}

// public setters
public void setOut( PrintStream output ) {
    out = output;
}

public void setSort( boolean sort ) {
    this.sort = sort;
}

public void setReorder( boolean reorder ) {
    this.reorder = reorder;
}

public void setTabWidth( int t ) {
    String tab = "";
    for ( int i = 0; i < t; i++ ) {
        tab += " ";
    }
    _TAB = tab;
}

// private methods
private void print( String s ) {
    out.print( s );
    out.flush();
}

private String getTab() {
    StringBuilder tabstr = new StringBuilder();
    for (int i = 0; i < indent; i++) {
        tabstr.append( _TAB );
    }
    return tabstr.toString();
}

private String getSpace( int num ) {
    StringBuilder spcstr = new StringBuilder();
    for (int i = 0; i < num; i++) {
        spcstr.append( _SPACE );
    }
    return spcstr.toString();
}

private String line( String s ) {
    return getTab() + s + _NEWLINE;
}

private String line() {
    return getTab() + _NEWLINE;
}

private String getText( StringBuilder sb ) {
    if ( sb == null ) return "";
    return sb.toString();
}

private void sort( List<String> l ) {
    if ( l == null ) return;
    Collections.sort( l );
}

private String cat( List<String> l, boolean pad ) {
    StringBuilder sb = new StringBuilder();
    if ( pad ) sb.append( line() );
    for ( String s : l ) {
        sb.append( s );
        if ( pad ) sb.append( line() );
    }
    return sb.toString();
}

}

target                        
                              : definition+;

definition                    
                              : projectDefinition
                              {
                                  print( getText( $projectDefinition.text ) );
                              }
                              | domainDefinition
                              {
                                  print( getText( $domainDefinition.text ) );
                              }
                              ;


//---------------------------------------------------------
// Project Definition
//---------------------------------------------------------

identifier
returns [StringBuilder text]
                              : Identifier
                              {
                                  $text = new StringBuilder( $Identifier.text );
                              }
                              ;


projectDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
    List<String> projectItems = new ArrayList<String>();
}
@after {
    $text = t;
}
                              : ^( PROJECT
                                   projectName
                                   description
                                   {
                                        t.append( getText( $description.text ) );
                                        t.append( line( _PROJECT + _SPACE + getText( $projectName.text ) + _SPACE + _IS ) );
                                        indent++;
                                   }
                                   ( projectDomainDefinition 
                                   {
                                       projectItems.add( getText( $projectDomainDefinition.text ) );
                                   }
                                   )*
                                   {
                                       if ( sort ) sort( projectItems );
                                       t.append( cat( projectItems, true ) );
                                       indent--;
                                   }
                                   pragmaList
                                   {
                                       t.append( line( _END + _SPACE + _PROJECT + _SEMI ) );
                                       t.append( getText( $pragmaList.text ) );
                                   }
                                   )              
                              ;

projectDomainDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
    List<String> projectDomainItems = new ArrayList<String>();
}
@after {
    $text = t;
}
                              : ^( DOMAIN
                                   projectDomainReference   
                                   description
                                   {
                                        t.append( getText( $description.text ) );
                                        t.append( line( _DOMAIN + _SPACE + getText( $projectDomainReference.text ) + _SPACE + _IS ) );
                                        indent++;
                                   }
                                   ( projectTerminatorDefinition    
                                   {
                                       projectDomainItems.add( getText( $projectTerminatorDefinition.text ) );
                                   }
                                   )*
                                   {
                                       if ( sort ) sort( projectDomainItems );
                                       t.append( cat( projectDomainItems, false ) );
                                       indent--;
                                   }
                                   pragmaList               
                                   {
                                       t.append( line( _END + _SPACE + _DOMAIN + _SEMI ) );
                                       t.append( getText( $pragmaList.text ) );
                                   }
                                 )                          
                              ;


projectName
returns [StringBuilder text]
                              :^( PROJECT_NAME
                                   identifier
                                   {
                                       $text = $identifier.text;
                                   }
                                )
                              ;


//---------------------------------------------------------
// Domain Definition
//---------------------------------------------------------

domainDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( DOMAIN
                                   domainName                    
                                   description
                                   {
                                        t.append( getText( $description.text ) );
                                        t.append( line( _DOMAIN + _SPACE + getText( $domainName.text ) + _SPACE + _IS ) );
                                        t.append( line() );
                                        indent++;
                                   }
                                   ( objectDeclaration
                                   {
                                       t.append( getText( $objectDeclaration.text ) );
                                   }
                                   | domainServiceDeclaration
                                   {
                                       t.append( line() );
                                       t.append( getText( $domainServiceDeclaration.text ) );
                                   }
                                   | domainTerminatorDefinition
                                   {
                                       t.append( getText( $domainTerminatorDefinition.text ) );
                                   }
                                   | relationshipDefinition
                                   {
                                       t.append( getText( $relationshipDefinition.text ) );
                                   }
                                   | objectDefinition
                                   {
                                       t.append( getText( $objectDefinition.text ) );
                                   }
                                   | typeDeclaration
                                   {
                                       t.append( getText( $typeDeclaration.text ) );
                                   }
                                   | typeForwardDeclaration
                                   {
                                       t.append( getText( $typeForwardDeclaration.text ) );
                                   }
                                   | exceptionDeclaration
                                   {
                                       t.append( getText( $exceptionDeclaration.text ) );
                                   }
                                   )*
                                   {
                                       indent--;
                                   }
                                   pragmaList                    
                                   {
                                       t.append( line() );
                                       t.append( line( _END + _SPACE + _DOMAIN + _SEMI ) );
                                       t.append( getText( $pragmaList.text ) );
                                   }
                                 )                              
                              ;

domainName
returns [StringBuilder text]
                              : ^( DOMAIN_NAME
                                   identifier               
                                   {
                                       $text = $identifier.text;
                                   }
                                 )
                              ;

domainReference
returns [StringBuilder text]
                              : domainName                  
                              {
                                  $text = $domainName.text;
                              }
                              ;


projectDomainReference
returns [StringBuilder text]
                              : domainName                  
                              {
                                  $text = $domainName.text;
                              }
                              ;



optionalDomainReference
returns [StringBuilder text]
                              : domainReference             
                              {
                                  $text = $domainReference.text;
                              }
                              | /* blank */                 
                              {
                                  $text = new StringBuilder();
                              }
                              ;



//---------------------------------------------------------
// Exception Declaration
//---------------------------------------------------------
exceptionDeclaration
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( EXCEPTION
                                   exceptionName            
                                   exceptionVisibility      
                                   pragmaList               
                                 )                          
                              {
                                  t.append( getTab() );
                                  t.append( getText( $exceptionVisibility.text ) );
                                  t.append( _SPACE + _EXCEPTION + _SPACE );
                                  t.append( getText( $exceptionName.text ) );
                                  t.append( _SEMI + _NEWLINE );
                                  t.append( getText( $pragmaList.text ) );
                              }
                              ;

exceptionName
returns [StringBuilder text]
                              : ^( EXCEPTION_NAME
                                   identifier)              
                              {
                                  $text = $identifier.text;
                              }
                              ;

exceptionReference
                              : optionalDomainReference
                                exceptionName               
                              ;
                                

exceptionVisibility
returns [StringBuilder text]
                              : PRIVATE                     
                              {
                                  $text = new StringBuilder( $PRIVATE.text );
                              }
                              | PUBLIC                      
                              {
                                  $text = new StringBuilder( $PUBLIC.text );
                              }
                              ;

//---------------------------------------------------------
// Type Definition
//---------------------------------------------------------

typeForwardDeclaration
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( TYPE_DECLARATION
                                   typeName                 
                                   typeVisibility
                                   pragmaList				
                                 )                          
                              {
                                  t.append( getTab() );
                                  t.append( getText( $typeVisibility.text ) );
                                  t.append( _SPACE + _TYPE + _SPACE );
                                  t.append( getText( $typeName.text ) );
                                  t.append( _SEMI + _NEWLINE );
                                  t.append( getText( $pragmaList.text ) );
                              }
                              ;
                              

typeDeclaration
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( TYPE
                                   typeName                 
                                   typeVisibility
                                   description
                                   pragmaList				
                                   typeDefinition			
                                 )                          
                              {
                                  t.append( getText( $description.text ) );
                                  t.append( getTab() );
                                  t.append( getText( $typeVisibility.text ) );
                                  t.append( _SPACE + _TYPE + _SPACE );
                                  t.append( getText( $typeName.text ) );
                                  t.append( _SPACE + _IS + _SPACE );
                                  t.append( getText( $typeDefinition.text ) );
                                  t.append( _SEMI + _NEWLINE );
                                  t.append( getText( $pragmaList.text ) );
                              }
                              ;
                              

typeDefinition
returns [StringBuilder text]
                              : structureTypeDefinition     
                              {
                                  $text = $structureTypeDefinition.text;
                              }
                              | enumerationTypeDefinition
                              {
                                  $text = $enumerationTypeDefinition.text;
                              }
                              | constrainedTypeDefinition   //TODO
                              | typeReference
                              {
                                  $text = $typeReference.text;
                              }
                              | unconstrainedArrayDefinition//TODO
                              ;

typeVisibility
returns [StringBuilder text]
                              : PRIVATE                     
                              {
                                  $text = new StringBuilder( $PRIVATE.text );
                              }
                              | PUBLIC                      
                              {
                                  $text = new StringBuilder( $PUBLIC.text );
                              }
                              ;



// Constrained Type
constrainedTypeDefinition
                              : ^( CONSTRAINED_TYPE
                                   typeReference
                                   typeConstraint
                                 )                          
                              ;

typeConstraint
                              : rangeConstraint             
                              | deltaConstraint             
                              | digitsConstraint            
                              ;

rangeConstraint
                              : ^( RANGE
                                   expression
                                 )                          
                              ;

deltaConstraint
                              : ^( DELTA
                                   expression
                                   rangeConstraint
                                 )                          
                              ;

digitsConstraint
                              : ^( DIGITS
                                   expression
                                   rangeConstraint
                                 )                          
                              ;

// Structure Type
structureTypeDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( STRUCTURE
                              {
                                  t.append( _STRUCTURE + _NEWLINE );
                                  indent++;
                              }
                                   ( structureComponentDefinition 
                                   {
                                       t.append( getText( $structureComponentDefinition.text ) );
                                   }
                                   )+
                                 )                          
                              {
                                  indent--;
                                  t.append( getTab() + _END + _SPACE + _STRUCTURE );
                              }
                              ;


structureComponentDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( COMPONENT_DEFINITION
                                   componentName
                                   typeReference
                                   {
                                       t.append( getTab() );
                                       t.append( getText( $componentName.text ) );
                                       t.append( _COLON + _SPACE );
                                       t.append( getText( $typeReference.text ) );
                                   }
                                   (expression //TODO finish all expressions
                                   {
                                       t.append( _SPACE + _ASSIGN + _SPACE );
                                       t.append( getText( $expression.text ) );
                                   }
                                   )?
                                   pragmaList
                                   {
                                       t.append( _SEMI + _NEWLINE );
                                       t.append( getText( $pragmaList.text ) );
                                   }
                                 )                          
                              ;

componentName
returns [StringBuilder text]
                              : ^( COMPONENT_NAME
                                   identifier
                                 )                          
                              {
                                  $text = $identifier.text;
                              }
                              ;


// Enumeration Type
enumerationTypeDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
    String sep = _SPACE;
    String end = _SPACE + _RPAREN;
    t.append( _ENUM + _SPACE + _LPAREN );
}
@after {
    t.append( end );
    $text = t;
}
                              : ^( ENUM
                                   ( enumerator             
                                   {
                                       t.append( sep + getText( $enumerator.text ) );
                                       sep = _COMMA + _SPACE;
                                   }
                                   )+
                                 )                          
                              ;

enumerator
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( ENUMERATOR
                                   enumeratorName
                                   {
                                       t.append( getText( $enumeratorName.text ) );
                                   }
                                   (expression
                                   {
                                       t.append( _SPACE + _ASSIGN + _SPACE );
                                       t.append( getText( $expression.text ) );
                                   }
                                   )?
                                 )                          
                              ;

enumeratorName
returns [StringBuilder text]
                              : ^( ENUMERATOR_NAME
                                   identifier
                                 )                          
                              {
                                  $text = $identifier.text;
                              }
                              ;


// Unconstrained array
unconstrainedArrayDefinition
                              : ^( UNCONSTRAINED_ARRAY
                                   index=typeReference
                                   contained=typeReference
                                 )                          
                              ;

//---------------------------------------------------------
// Type Reference
//---------------------------------------------------------

/*
typeReference
                              : namedTypeRef                
                              | constrainedArrayTypeRef     
                              | instanceTypeRef             
                              | sequenceTypeRef             
                              | arrayTypeRef                
                              | setTypeRef                  
                              | bagTypeRef                  
                              | dictionaryTypeRef           
                              ;
                              */

typeReference
returns [StringBuilder text]
                              : TYPE_REF
                              {
                                  $text = new StringBuilder( $TYPE_REF.text );
                              }
                              ;



instanceTypeRef
                              : ^( INSTANCE
                                   objectReference
                                   ANONYMOUS?
                                 )                          
                              ;

namedTypeRef
                              : ^( NAMED_TYPE
                                   optionalDomainReference
                                   typeName
                                   ANONYMOUS?
                                 )                          
                              ;

userDefinedTypeRef
                              : ^( NAMED_TYPE
                                   optionalDomainReference
                                   typeName
                                 )                          
                              ;

constrainedArrayTypeRef
                              : ^( CONSTRAINED_ARRAY
                                   userDefinedTypeRef
                                   arrayBounds
                                 )                          
                              ;


sequenceTypeRef
                              : ^( SEQUENCE
                                   typeReference
                                   expression?
                                   ANONYMOUS?
                                 )                          
                              ;

arrayTypeRef
                              : ^( ARRAY
                                   typeReference
                                   arrayBounds
                                   ANONYMOUS?
                                 )                          
                              ;

setTypeRef
                              : ^( SET
                                   typeReference
                                   ANONYMOUS?
                                 )                          
                              ;

bagTypeRef
                              : ^( BAG
                                   typeReference
                                   ANONYMOUS?
                                 )                          
                              ;

dictionaryTypeRef
                              : ^( DICTIONARY
                                   (^(KEY   key=typeReference))?
                                   (^(VALUE value=typeReference))?
                                   ANONYMOUS?
                                 )                          
                              ;
typeName
returns [StringBuilder text]
                              : ^( TYPE_NAME
                                   identifier )             
                              {
                                  $text = $identifier.text;
                              }
                              ;

arrayBounds
                              : ^( ARRAY_BOUNDS
                                   expression )             
                              ;

//---------------------------------------------------------
// Terminator Definition
//---------------------------------------------------------

terminatorName
returns [StringBuilder text]
                              : ^( TERMINATOR_NAME
                                   identifier )         
                              {
                                  $text = $identifier.text;
                              }
                              ;


domainTerminatorDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}

                              : ^( TERMINATOR_DEFINITION
                                   terminatorName             
                                   description
                                   {
                                        t.append( getText( $description.text ) );
                                        t.append( line( _TERMINATOR + _SPACE + getText( $terminatorName.text ) + _SPACE + _IS ) );
                                   }
                                   pragmaList                 
                                   {
                                       indent++;
                                   }
                                   ( terminatorServiceDeclaration
                                   {
                                       t.append( line() );
                                       t.append( getText( $terminatorServiceDeclaration.text ) );
                                   }
                                   )*
                                   {
                                       indent--;
                                       t.append( line() );
                                       t.append( line( _END + _SPACE + _TERMINATOR + _SEMI ) );
                                       t.append( getText( $pragmaList.text ) );
                                   }
                                 )
                              ;

projectTerminatorDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
    List<String> projectTerminatorServices = new ArrayList<String>();
}
@after {
    $text = t;
}
                              : ^( TERMINATOR_DEFINITION
                                   terminatorName
                                   description
                                   {
                                        t.append( getText( $description.text ) );
                                        t.append( line( _TERMINATOR + _SPACE + getText( $terminatorName.text ) + _SPACE + _IS ) );
                                   }
                                   pragmaList                 
                                   {
                                       indent++;
                                   }
                                   ( projectTerminatorServiceDeclaration
                                   {
                                       projectTerminatorServices.add( getText( $projectTerminatorServiceDeclaration.text ) );
                                   }
                                   )*
                                   {
                                       if ( sort ) sort( projectTerminatorServices );
                                       t.append( cat( projectTerminatorServices, false ) );
                                       indent--;
                                       t.append( line( _END + _SPACE + _TERMINATOR + _SEMI ) );
                                       t.append( getText( $pragmaList.text ) );
                                   }
                                 )
                              ;



terminatorServiceDeclaration
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( TERMINATOR_SERVICE_DECLARATION
                                   serviceVisibility
                                   serviceName
                                   description
                                   parameterList
                                   {
                                       t.append( getText( $description.text ) );
                                       t.append( getTab() );
                                       t.append( getText( $serviceVisibility.text ) );
                                       t.append( _SPACE );
                                       t.append( $TERMINATOR_SERVICE_DECLARATION.text );
                                       t.append( _SPACE );
                                       t.append( getText( $serviceName.text ) );
                                       t.append( _SPACE );
                                       t.append( getText( $parameterList.text ) );
                                   }
                                   (returnType
                                   {
                                       t.append( _SPACE + _RETURN + _SPACE );
                                       t.append( getText( $returnType.text ) );
                                   }
                                   )?
                                   {
                                       t.append( _SEMI );
                                   }
                                   pragmaList
                                   {
                                       t.append( _NEWLINE );
                                       t.append( getText( $pragmaList.text ) );
                                   }
                                 )
                                                            
                              ;

projectTerminatorServiceDeclaration
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( TERMINATOR_SERVICE_DECLARATION
                                   serviceVisibility
                                   serviceName              
                                   description
                                   parameterList
                                   {
                                       t.append( getText( $description.text ) );
                                       t.append( getTab() );
                                       t.append( getText( $serviceVisibility.text ) );
                                       t.append( _SPACE );
                                       t.append( $TERMINATOR_SERVICE_DECLARATION.text );
                                       t.append( _SPACE );
                                       t.append( getText( $serviceName.text ) );
                                       t.append( _SPACE );
                                       t.append( getText( $parameterList.text ) );
                                   }
                                   (returnType
                                   {
                                       t.append( _SPACE + _RETURN + _SPACE );
                                       t.append( getText( $returnType.text ) );
                                   }
                                   )?
                                   {
                                       t.append( _SEMI );
                                   }
                                   pragmaList
                                   {
                                       t.append( _NEWLINE );
                                       t.append( getText( $pragmaList.text ) );
                                   }
                                 )
                                                            
                              ;


//---------------------------------------------------------
// Object Definition
//---------------------------------------------------------

objectName
returns [StringBuilder text]
                              : ^( OBJECT_NAME
                                   identifier )             
                              {
                                  $text = $identifier.text;
                              }
                              ;


objectReference
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : optionalDomainReference
                                objectName                  
                                {
                                    String dom = getText( $optionalDomainReference.text );
                                    if ( !dom.isEmpty() ) {
                                        t.append( dom + _SCOPE );
                                    }
                                    t.append( getText( $objectName.text ) );
                                }
                              ;

fullObjectReference
                              : domainReference
                                objectName                  
                              ;


optionalObjectReference
returns [StringBuilder text]
                              : objectReference         
                              {
                                  $text = $objectReference.text;
                              }
                              | /* blank */
                              {
                                  $text = new StringBuilder();
                              }
                              ;
attributeName
returns [StringBuilder text]
                              : ^( ATTRIBUTE_NAME
                                   identifier )             
                              {
                                  $text = $identifier.text;
                              }
                              ;

objectDeclaration
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( OBJECT_DECLARATION
                                   objectName
                                   pragmaList
                                 )                          
                              {
                                  t.append( line( _OBJECT + _SPACE + getText( $objectName.text ) + _SEMI ) );
                                  t.append( getText( $pragmaList.text ) );
                              }
                              ;


objectDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( OBJECT_DEFINITION
                                   objectName               
                                   {
                                       t.append( line( _OBJECT + _SPACE + getText( $objectName.text ) + _SPACE + _IS ) );
                                       indent++;
                                   }
                                   ( attributeDefinition
                                   {
                                       t.append( getText( $attributeDefinition.text ) );
                                   }
                                   | identifierDefinition
                                   {
                                       t.append( getText( $identifierDefinition.text ) );
                                   }
                                   | objectServiceDeclaration
                                   {
                                       t.append( getText( $objectServiceDeclaration.text ) );
                                   }
                                   | eventDefinition
                                   {
                                       t.append( getText( $eventDefinition.text ) );
                                   }
                                   | stateDeclaration
                                   {
                                       t.append( getText( $stateDeclaration.text ) );
                                   }
                                   | transitionTable
                                   {
                                       t.append( getText( $transitionTable.text ) );
                                   }
                                   )*
                                   {
                                       indent--;
                                   }
                                   description
                                   pragmaList                 
                                   {
                                       t.insert( 0, getText( $description.text ) );
                                       t.append( line( _END + _SPACE + _OBJECT + _SEMI ) );
                                       t.append( getText( $pragmaList.text ) );
                                   }

                                 )
                              ;

attributeDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( ATTRIBUTE_DEFINITION
                                   attributeName            
                                   {
                                       t.append( getTab() + getText( $attributeName.text ) + _COLON + _SPACE );
                                   }
                                   (PREFERRED
                                   {
                                       t.append( $PREFERRED.text + _SPACE );
                                   }
                                   )?
                                   (UNIQUE
                                   {
                                       t.append( $UNIQUE.text + _SPACE );
                                   }
                                   )?
                                   {
                                       boolean first_ref = true;
                                       String sep = "";
                                   }
                                   ( attReferential         
                                   {
                                       if ( first_ref ) {
                                           t.append( _REFERENTIAL + _SPACE + _LPAREN + _SPACE );
                                           first_ref = false;
                                       }
                                       t.append( sep + getText( $attReferential.text ) );
                                       sep = _COMMA + _SPACE;
                                   }
                                   )*
                                   description
                                   typeReference
                                   {
                                       if ( t.indexOf( _REFERENTIAL ) != -1 ) {
                                           t.append( _SPACE + _RPAREN + _SPACE );
                                       }
                                       t.insert( 0, getText( $description.text ) );
                                       t.append( getText( $typeReference.text ) );
                                   }
                                   (expression
                                   {
                                       t.append( _SPACE + _ASSIGN + _SPACE );
                                       t.append( getText( $expression.text ) );
                                   }
                                   )?
                                   pragmaList
                                   {
                                       t.append( _SEMI + _NEWLINE );
                                       t.append( getText( $pragmaList.text ) );
                                   }
                                 )                          

                              ;

attReferential
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( REFERENTIAL
                                   relationshipSpec
                                   attributeName
                                 )                          
                              {
                                  t.append( getText( $relationshipSpec.text ) );
                                  t.append( _DOT );
                                  t.append( getText( $attributeName.text ) );
                              }
                              ;


relationshipSpec
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( RELATIONSHIP_SPEC
                                   relationshipReference    
                                   {
                                       t.append( getText( $relationshipReference.text ) );
                                   }
                                   ( objOrRole
                                   {
                                       t.append( _DOT + getText( $objOrRole.text ) );
                                   }
                                   ( objectReference
                                   {
                                       t.append( _DOT + getText( $objectReference.text ) );
                                   }
                                   )? 
                                   )?
                                 ) 													
                              ;

objOrRole
returns [StringBuilder text]
                              : identifier                  
                              {
                                  $text = $identifier.text;
                              }
                              ;


objectServiceDeclaration
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( OBJECT_SERVICE_DECLARATION
                                   serviceVisibility
                                   {
                                       t.append( getTab() );
                                       t.append( getText( $serviceVisibility.text ) );
                                       t.append( _SPACE );
                                   }
                                   (INSTANCE
                                   {
                                       t.append( _INSTANCE + _SPACE );
                                   }
                                   (relationshipReference
                                   {
                                       t.append( _DEFERRED + _SPACE + _LPAREN + _SPACE + getText( $relationshipReference.text ) + _SPACE + _RPAREN + _SPACE );
                                   }
                                   )?
                                   )?
                                   serviceName
                                   description
                                   parameterList
                                   {
                                       t.insert( 0, getText( $description.text ) );
                                       t.append( $OBJECT_SERVICE_DECLARATION.text );
                                       t.append( _SPACE );
                                       t.append( getText( $serviceName.text ) );
                                       t.append( _SPACE );
                                       t.append( getText( $parameterList.text ) );
                                   }
                                   (returnType
                                   {
                                       t.append( _SPACE + _RETURN + _SPACE );
                                       t.append( getText( $returnType.text ) );
                                   }
                                   )?
                                   {
                                       t.append( _SEMI );
                                   }
                                   pragmaList
                                   {
                                       t.append( _NEWLINE );
                                       t.append( getText( $pragmaList.text ) );
                                   }
                                 )                          
                              ;

identifierDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( IDENTIFIER
                                   {
                                       t.append( getTab() + _IDENTIFIER + _SPACE + _IS + _SPACE + _LPAREN + _SPACE );
                                       String sep = "";
                                   }
                                   ( attributeName          
                                   {
                                       t.append( sep + getText( $attributeName.text ) );
                                       sep = _COMMA + _SPACE;
                                   }
                                   )+
                                   pragmaList
                                   {
                                       t.append( _SPACE + _RPAREN + _SEMI + _NEWLINE );
                                       t.append( getText( $pragmaList.text ) );
                                   }
                                 )                     
                              ;

eventDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( EVENT         
                                   eventName                
                                   eventType                
                                   description
                                   parameterList
                                   pragmaList               
                                 )
                              {
                                  t.append( getText( $description.text ) );
                                  t.append( getTab() );
                                  String evt_type = getText( $eventType.text );
                                  if ( !evt_type.isEmpty() ) {
                                      t.append( evt_type + _SPACE );
                                  }
                                  t.append( _EVENT + _SPACE );
                                  t.append( getText( $eventName.text ) );
                                  t.append( _SPACE );
                                  t.append( getText( $parameterList.text ) );
                                  t.append( _SEMI + _NEWLINE );
                                  t.append( getText( $pragmaList.text ) );
                              }
                              ;

eventName
returns [StringBuilder text]
                              : ^( EVENT_NAME
                                   identifier )             
                              {
                                  $text = $identifier.text;
                              }
                              ;

eventType
returns [StringBuilder text]
                              : ASSIGNER                    
                              {
                                  $text = new StringBuilder( $ASSIGNER.text );
                              }
                              | CREATION                    
                              {
                                  $text = new StringBuilder( $CREATION.text );
                              }
                              | NORMAL                      
                              {
                                  $text = new StringBuilder();
                              }
                              ;

stateDeclaration
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( STATE
                                   stateName                
                                   stateType               
                                   description
                                   parameterList
                                   pragmaList              
                                )                           
                              {
                                  t.append( getText( $description.text ) );
                                  t.append( getTab() );
                                  String st_type = getText( $stateType.text );
                                  if ( !st_type.isEmpty() ) {
                                      t.append( st_type + _SPACE );
                                  }
                                  t.append( _STATE + _SPACE );
                                  t.append( getText( $stateName.text ) );
                                  t.append( _SPACE );
                                  t.append( getText( $parameterList.text ) );
                                  t.append( _SEMI + _NEWLINE );
                                  t.append( getText( $pragmaList.text ) );
                              }
                              ;

stateName
returns [StringBuilder text]
                              : ^( STATE_NAME
                                   identifier )             
                              {
                                  $text = $identifier.text;
                              }
                              ;

stateType
returns [StringBuilder text]
                              : ASSIGNER                    
                              {
                                  $text = new StringBuilder( $ASSIGNER.text );
                              }
                              | START                       
                              {
                                  $text = new StringBuilder( $START.text );
                              }
                              | CREATION                    
                              {
                                  $text = new StringBuilder( $CREATION.text );
                              }
                              | TERMINAL                    
                              {
                                  $text = new StringBuilder( $TERMINAL.text );
                              }
                              | NORMAL                      
                              {
                                  $text = new StringBuilder();
                              }
                              ;


transitionTable
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( TRANSITION_TABLE
                                   transTableType
                                   {
                                       t.append( getTab() );
                                       String tabType = getText( $transTableType.text );
                                       if ( !tabType.isEmpty() ) {
                                           t.append( tabType + _SPACE );
                                       }
                                       t.append( _TRANSITION + _SPACE + _IS + _NEWLINE );
                                       indent++;
                                   }
                                   ( transitionRow          
                                   {
                                       t.append( getText( $transitionRow.text ) );
                                   }
                                   )+
                                   {
                                       indent--;
                                   }
                                   pragmaList
                                   {
                                       t.append( line( _END + _SPACE + _TRANSITION + _SEMI ) );
                                       t.append( getText( $pragmaList.text ) );
                                   }
                                 )                          
                              ;

transTableType
returns [StringBuilder text]
                              : ASSIGNER                    
                              {
                                  $text = new StringBuilder( $ASSIGNER.text );
                              }
                              | NORMAL                      
                              {
                                  $text = new StringBuilder();
                              }
                              ;

transitionRow
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( TRANSITION_ROW
                                   startState
                                   {
                                       t.append( getTab() + getText( $startState.text ) + _SPACE + _LPAREN + _SPACE );
                                       int len = t.length();
                                       String sep = "";
                                   }
                                   ( transitionOption
                                   {
                                       t.append( sep + getText( $transitionOption.text ) );
                                       sep = _COMMA + _NEWLINE + getSpace(len);
                                   }
                                   )+
                                   pragmaList
                                   {
                                       t.append( _SPACE + _RPAREN + _SEMI + _NEWLINE );
                                       t.append( getText( $pragmaList.text ) );
                                   }
                                )                           
                              ;

transitionOption
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( TRANSITION_OPTION
                                   incomingEvent
                                   endState
                                 )                          
                              {
                                  t.append( getText( $incomingEvent.text ) );
                                  t.append( _SPACE + _GOES_TO + _SPACE );
                                  t.append( getText( $endState.text ) );
                              }
                              ;

incomingEvent
returns [StringBuilder text]
                              : ^( EVENT
                                   eventReference           
                                 )
                              {
                                  $text = $eventReference.text;
                              }
                              ;

startState
returns [StringBuilder text]
                              : NON_EXISTENT                
                              {
                                  $text = new StringBuilder( _NON_EXISTENT );
                              }
                              | stateName                   
                              {
                                  $text = $stateName.text;
                              }
                              ;

endState
returns [StringBuilder text]
                              : stateName                   
                              {
                                  $text = $stateName.text;
                              }
                              | IGNORE                      
                              {
                                  $text = new StringBuilder( _IGNORE );
                              }
                              | CANNOT_HAPPEN               
                              {
                                  $text = new StringBuilder( _CANNOT_HAPPEN );
                              }
                              ;

eventReference
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : optionalObjectReference
                                eventName                   
                                {
                                    String obj = getText( $optionalObjectReference.text );
                                    if ( !obj.isEmpty() ) {
                                        t.append( obj + _DOT );
                                    }
                                    t.append( getText( $eventName.text ) );
                                }
                              ;


//---------------------------------------------------------
// Service Declaration
//---------------------------------------------------------

domainServiceDeclaration
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( DOMAIN_SERVICE_DECLARATION
                                   serviceVisibility
                                   serviceName
                                   description
                                   parameterList
                                   {
                                       t.append( getText( $description.text ) );
                                       t.append( getTab() );
                                       t.append( getText( $serviceVisibility.text ) );
                                       t.append( _SPACE );
                                       t.append( $DOMAIN_SERVICE_DECLARATION.text );
                                       t.append( _SPACE );
                                       t.append( getText( $serviceName.text ) );
                                       t.append( _SPACE );
                                       t.append( getText( $parameterList.text ) );
                                   }
                                   (returnType
                                   {
                                       t.append( _SPACE + _RETURN + _SPACE );
                                       t.append( getText( $returnType.text ) );
                                   }
                                   )?
                                   {
                                       t.append( _SEMI );
                                   }
                                   pragmaList
                                   {
                                       t.append( _NEWLINE );
                                       t.append( getText( $pragmaList.text ) );
                                   }
                                 )
                              ;

parameterDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( PARAMETER_DEFINITION
                                   parameterName
                                   parameterMode
                                   parameterType)           
                              {
                                  t.append( getText( $parameterName.text ) );
                                  t.append( _COLON + _SPACE );
                                  t.append( getText( $parameterMode.text ) );
                                  t.append( _SPACE );
                                  t.append( getText( $parameterType.text ) );
                              }
                              ;
                              
parameterList
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
    String sep = _SPACE;
    String end = _RPAREN;
    t.append( _LPAREN );
}
@after {
    t.append( end );
    $text = t;
}

                              : ( parameterDefinition       
                              {
                                  t.append( sep + getText( $parameterDefinition.text ) );
                                  sep = _COMMA + _SPACE;
                                  end = _SPACE + _RPAREN;
                              }
                               )*
                              ;


serviceVisibility
returns [StringBuilder text]
                              : PRIVATE                     
                              {
                                  $text = new StringBuilder( $PRIVATE.text );
                              }
                              | PUBLIC                      
                              {
                                  $text = new StringBuilder( $PUBLIC.text );
                              }
                              ;

parameterMode
returns [StringBuilder text]
                              : IN                          
                              {
                                  $text = new StringBuilder( $IN.text );
                              }
                              | OUT                         
                              {
                                  $text = new StringBuilder( $OUT.text );
                              }
                              ;


serviceName
returns [StringBuilder text]
                              : ^( SERVICE_NAME
                                   identifier )             
                              {
                                  $text = $identifier.text;
                              }
                              ;

parameterName
returns [StringBuilder text]
                              : ^( PARAMETER_NAME
                                   identifier )             
                              {
                                  $text = $identifier.text;
                              }
                              ;

parameterType
returns [StringBuilder text]
                              : ^( PARAMETER_TYPE
                                   typeReference )
                              {
                                  $text = $typeReference.text;
                              }
                              ;

returnType
returns [StringBuilder text]
                              : ^( RETURN_TYPE
                                   typeReference )
                              {
                                  $text = $typeReference.text;
                              }
                              ;


//---------------------------------------------------------
// Relationship Definition
//---------------------------------------------------------


relationshipDefinition
returns [StringBuilder text]
                              : regularRelationshipDefinition
                              {
                                  $text = $regularRelationshipDefinition.text;
                              }
                              | assocRelationshipDefinition   
                              {
                                  $text = $assocRelationshipDefinition.text;
                              }
                              | subtypeRelationshipDefinition 
                              {
                                  $text = $subtypeRelationshipDefinition.text;
                              }
                              ;



regularRelationshipDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( REGULAR_RELATIONSHIP_DEFINITION
                                   relationshipName
                                   description
                                   leftToRight=halfRelationshipDefinition
                                   rightToLeft=halfRelationshipDefinition
                                   pragmaList
                                 )                          
                              {
                                  t.append( getText( $description.text ) );
                                  t.append( getTab() + _RELATIONSHIP + _SPACE );
                                  t.append( getText( $relationshipName.text ) );
                                  t.append( _SPACE + _IS + _SPACE );
                                  int len = t.length();
                                  t.append( getText( $leftToRight.text ) );
                                  t.append( _COMMA + _NEWLINE );
                                  t.append( getSpace(len) );
                                  t.append( getText( $rightToLeft.text ) );
                                  t.append( _SEMI + _NEWLINE );
                                  t.append( getText( $pragmaList.text ) );
                              }
                              ;


assocRelationshipDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( ASSOCIATIVE_RELATIONSHIP_DEFINITION
                                   relationshipName
                                   description
                                   leftToRight=halfRelationshipDefinition
                                   rightToLeft=halfRelationshipDefinition
                                   assocObj=objectReference
                                   pragmaList
                                 )                          
                              {
                                  t.append( getText( $description.text ) );
                                  t.append( getTab() + _RELATIONSHIP + _SPACE );
                                  t.append( getText( $relationshipName.text ) );
                                  t.append( _SPACE + _IS + _SPACE );
                                  int len = t.length();
                                  t.append( getText( $leftToRight.text ) );
                                  t.append( _COMMA + _NEWLINE );
                                  t.append( getSpace(len) );
                                  t.append( getText( $rightToLeft.text ) );
                                  t.append( _NEWLINE );
                                  t.append( getSpace(len) );
                                  t.append( _USING + _SPACE );
                                  t.append( getText( $assocObj.text ) );
                                  t.append( _SEMI + _NEWLINE );
                                  t.append( getText( $pragmaList.text ) );
                              }
                              ;

halfRelationshipDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( HALF_RELATIONSHIP
                                   from=objectReference
                                   conditionality
                                   rolePhrase
                                   multiplicity
                                   to=objectReference
                                 )                          
                              {
                                  t.append( getText( $from.text ) );
                                  t.append( _SPACE );
                                  t.append( getText( $conditionality.text ) );
                                  t.append( _SPACE );
                                  t.append( getText( $rolePhrase.text ) );
                                  t.append( _SPACE );
                                  t.append( getText( $multiplicity.text ) );
                                  t.append( _SPACE );
                                  t.append( getText( $to.text ) );
                              }
                              ;


subtypeRelationshipDefinition
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( SUBTYPE_RELATIONSHIP_DEFINITION
                                   relationshipName
                                   description
                                   supertype=objectReference
                                   {
                                        t.append( getText( $description.text ) );
                                        t.append( getTab() + _RELATIONSHIP + _SPACE );
                                        t.append( getText( $relationshipName.text ) );
                                        t.append( _SPACE + _IS + _SPACE );
                                        t.append( getText( $supertype.text ) );
                                        t.append( _SPACE + _IS_A + _SPACE + _LPAREN + _SPACE );
                                        int len = t.length();
                                        String sep = "";
                                   }
                                   (subtype=objectReference   
                                   {
                                       t.append( sep + getText( $subtype.text ) );
                                       sep = _COMMA + _SPACE;
                                   }
                                   )+
                                   {
                                       t.append( _SPACE + _RPAREN + _SEMI + _NEWLINE );
                                   }
                                   pragmaList
                                   {
                                       t.append( getText( $pragmaList.text ) );
                                   }
                                 )                          
                              ;

rolePhrase
returns [StringBuilder text]
                              : ^( ROLE_PHRASE
                                   identifier )             
                              {
                                  $text = $identifier.text;
                              }
                              ;

conditionality
returns [StringBuilder text]
                              : UNCONDITIONALLY             
                              {
                                  $text = new StringBuilder( $UNCONDITIONALLY.text );
                              }
                              | CONDITIONALLY               
                              {
                                  $text = new StringBuilder( $CONDITIONALLY.text );
                              }
                              ;

multiplicity
returns [StringBuilder text]
                              : ONE                         
                              {
                                  $text = new StringBuilder( $ONE.text );
                              }
                              | MANY                        
                              {
                                  $text = new StringBuilder( $MANY.text );
                              }
                              ;


relationshipName
returns [StringBuilder text]
                              : ^( RELATIONSHIP_NAME
                                   RelationshipName  
                                 )                          
                              {
                                  $text = new StringBuilder( $RelationshipName.text );
                              }
                              ;
                              

relationshipReference
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : optionalDomainReference
                                relationshipName            
                                {
                                    String dom = getText( $optionalDomainReference.text );
                                    if ( !dom.isEmpty() ) {
                                        t.append( dom + _SCOPE );
                                    }
                                    t.append( getText( $relationshipName.text ) );
                                }
                              ;


//---------------------------------------------------------
// Pragma Definition
//---------------------------------------------------------


pragmaList
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ( pragma
                                {
                                    t.append( line( getText( $pragma.text ) ) );
                                }
                                )*                          
                              ;

pragma
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( PRAGMA
                                   pragmaName               
                                   {
                                       t.append( _PRAGMA + _SPACE + getText( $pragmaName.text ) + _LPAREN );
                                       String sep = _SPACE;
                                       String end = _RPAREN + _SEMI;
                                   }
                                   ( pragmaValue            
                                   {
                                       t.append( sep + getText( $pragmaValue.text ) );
                                       sep = _COMMA + _SPACE;
                                       end = _SPACE + _RPAREN + _SEMI;
                                   }
                                   )*
                                   {
                                       t.append( end );
                                   }
                                 )                          
                              ;

pragmaValue
returns [StringBuilder text]
                              : identifier                  
                              {
                                  $text = $identifier.text;
                              }
                              | literalExpression           
                              {
                                  $text = $literalExpression.text;
                              }
                              ;

pragmaName
returns [StringBuilder text]
                              : ^( PRAGMA_NAME
                                   identifier               
                                   {
                                       $text = $identifier.text;
                                   }
                                 )
                              ;

//---------------------------------------------------------
// Descriptions
//---------------------------------------------------------

description                   
returns [StringBuilder text]
@init {
    StringBuilder t = new StringBuilder();
}
@after {
    $text = t;
}
                              : ^( DESCRIPTION          
                                   (Description             
                                   {
                                       t.append( getTab() + $Description.text );
                                   }
                                   )*
                                 )
                              ;

//---------------------------------------------------------
// Dynamic Behaviour
//---------------------------------------------------------

/*  This rule has been added to allow to parse any activity action body file
    without knowledge of what type of activity it contained - LPS */
activityDefinition            
                              : domainServiceDefinition
                              | terminatorServiceDefinition
                              | objectServiceDefinition
                              | stateDefinition
                              ;


domainServiceDefinition
                              : ^( DOMAIN_SERVICE_DEFINITION
                                   serviceVisibility
                                   domainReference
                                   serviceName
                                   parameterList
                                   returnType?
                                   codeBlock
                                   pragmaList
                                 )                                                   
                              ;


terminatorServiceDefinition
                              : ^( TERMINATOR_SERVICE_DEFINITION
                                   serviceVisibility
                                   domainReference
                                   terminatorName
                                   serviceName
                                   parameterList
                                   returnType?
                                   codeBlock
                                   pragmaList
                                 )                                                   
                              ;


projectTerminator
                              : ^( TERMINATOR_SERVICE_DEFINITION
                                   serviceVisibility
                                   domainReference
                                   terminatorName
                                   serviceName
                                   parameterList
                                   returnType?
                                   codeBlock         
                                   pragmaList
                                 )                                                   
                              ;



objectServiceDefinition
                              :^( OBJECT_SERVICE_DEFINITION
                                   serviceVisibility
                                   INSTANCE?
                                   fullObjectReference
                                   serviceName
                                   parameterList
                                   returnType?
                                   codeBlock
                                   pragmaList
                                 )                          
                              ;


stateDefinition
                              : ^( STATE_DEFINITION
                                   stateType
                                   fullObjectReference
                                   stateName
                                   parameterList
                                   codeBlock
                                   pragmaList
                                 )                          
                              ;



//---------------------------------------------------------
// Statements
//---------------------------------------------------------

statement
                              : ^( STATEMENT
                                   ( codeBlock       
                                   | assignmentStatement    
                                   | streamStatement        
                                   | callStatement          
                                   | exitStatement          
                                   | returnStatement        
                                   | delayStatement         
                                   | raiseStatement         
                                   | deleteStatement        
                                   | eraseStatement         
                                   | linkStatement          
                                   | scheduleStatement      
                                   | cancelTimerStatement   
                                   | generateStatement      
                                   | ifStatement            
                                   | caseStatement          
                                   | forStatement           
                                   | whileStatement         
                                   |                        
                                   )
                                   pragmaList
                                 )
                              ;

statementList
                              : ^( STATEMENT_LIST
                                   ( statement                 
                                   )*
                                 )
                              ;


assignmentStatement
                              : ^( ASSIGN
                                   lhs=expression rhs=expression
                                 )                          
                              ;

streamStatement
                              : ^( STREAM_STATEMENT
                                   expression
                                   ( streamOperator         
                                   )+
                                 )                          
                              ;

streamOperator
                              : ^( ( STREAM_IN              
                                   | STREAM_OUT             
                                   | STREAM_LINE_IN         
                                   | STREAM_LINE_OUT        
                                   ) expression
                                 )                          
                              ;

callStatement
                              : ^( CALL
                                   expression               
                                   ( argument               
                                   )*                       
                                 )                          

                              ;


exitStatement
                              : ^( EXIT
                                   condition?
                                 )                          
                              ;

returnStatement
                              : ^( RETURN
                                   expression              
                                 )                          
                              ;

delayStatement
                              : ^( DELAY
                                   expression
                                 )                         
                              ;

raiseStatement
                              : ^( RAISE
                                   exceptionReference
                                   expression?
                                 )                          
                              ;

deleteStatement
                              : ^( DELETE
                                   expression
                                 )                          
                              ;

eraseStatement
                              : ^( ERASE
                                   expression
                                 )                          
                              ;

linkStatement
                              : ^( linkStatementType
                                   lhs=expression      
                                   relationshipSpec
                                   (rhs=expression
                                    assoc=expression? )?
                                 )                          
                              ;

linkStatementType
                              : LINK                        
                              | UNLINK                      
                              ;


cancelTimerStatement
                             : ^( CANCEL
                                  timerId=expression )    
                             ;
                              
scheduleStatement
                              : ^( SCHEDULE
                                   timerId=expression
                                   generateStatement
                                   scheduleType
                                   time=expression
                                   period=expression?
                                 )                         
                              ;
scheduleType
                              : AT											    
                              | DELAY									      
                              ;



generateStatement
                              : ^( GENERATE
                                   eventReference
                                   ( argument               
                                   )*                       
                                   expression? )            
                              ;

ifStatement
                              : ^( IF
                                   condition
                                   statementList            
                                   ( elsifBlock             
                                   )*              
                                   ( elseBlock              
                                   )?
                                 )                          
                              ;


elsifBlock
                              : ^( ELSIF
                                   condition
                                   statementList )          
                              ;

elseBlock
                              : ^( ELSE
                                   statementList )          
                              ;


whileStatement
                              : ^( WHILE
                                   condition
                                   statementList )          
                              ;

condition
                              : ^( CONDITION
                                   expression )             
                              ;


caseStatement
                              :^( CASE
                                  expression
                                  ( caseAlternative         
                                  )*
                                  ( caseOthers              
                                  )?
                                )                           
                              ;

caseAlternative
                              : ^( WHEN                     
                                   ( choice                 
                                   )+
                                   statementList )         
                              ;

choice
                              : ^( CHOICE
                                   expression)              
                              ;

caseOthers
                              : ^( OTHERS
                                   statementList )          
                              ;

forStatement
                              : ^( FOR
                                   loopVariableSpec         
                                   ^( STATEMENT_LIST 
                                      ( statement               
                                      )*
                                    ) 
                                 )
                              ;

loopVariableSpec
                              : ^( LOOP_VARIABLE
                                   identifier
                                   REVERSE?
                                   expression )             
                              ;



//---------------------------------------------------------
// Code Blocks
//---------------------------------------------------------

codeBlock
                              :^( CODE_BLOCK                
                                  ( variableDeclaration     
                                  )*     
                                  ^(STATEMENT_LIST ( statement               
                                  )* )
                                  ( exceptionHandler        
                                  )*
                                  ( otherHandler            
                                  )?
                                )
                              ;



variableDeclaration
                              : ^( VARIABLE_DECLARATION
                                   variableName
                                   READONLY?
                                   typeReference
                                   expression?
                                   pragmaList)
                              ;


exceptionHandler
                              : ^( EXCEPTION_HANDLER
                                   exceptionReference       
                                   ^(STATEMENT_LIST ( statement               
                                   )* )
                                 )
                              ;

otherHandler
                              : ^( OTHER_HANDLER            
                                   ^(STATEMENT_LIST ( statement              
                                   )* )
                                 )
                              ;

variableName
                              : ^( VARIABLE_NAME
                                   identifier )             
                              ;

//---------------------------------------------------------
// Expression Definition
//---------------------------------------------------------


expression
returns [StringBuilder text]
                              : binaryExpression            
                              | unaryExpression             
                              | rangeExpression             
                              | aggregateExpression         
                              | linkExpression              
                              | navigateExpression          
                              | correlateExpression         
                              | orderByExpression           
                              | createExpression            
                              | findExpression              
                              | dotExpression               
                              | terminatorServiceExpression 
                              | callExpression              
                              | sliceExpression             
                              | primeExpression             
                              | nameExpression              
                              | literalExpression           
                              {
                                  $text = new StringBuilder( $literalExpression.text );
                              }
                              ;

binaryExpression
                              : ^( binaryOperator
                                   lhs=expression
                                   rhs=expression
                                 )                          
                              ;


binaryOperator
                              : AND                                        
                              | CONCATENATE                 
                              | DISUNION                    
                              | DIVIDE                      
                              | EQUAL                       
                              | GT                          
                              | GTE                         
                              | INTERSECTION                
                              | LT                          
                              | LTE                         
                              | MINUS                       
                              | MOD                         
                              | NOT_EQUAL                   
                              | NOT_IN                      
                              | OR                          
                              | PLUS                        
                              | POWER                       
                              | REM                         
                              | TIMES                       
                              | UNION                       
                              | XOR                         
                              ;

unaryExpression
                              :^( unaryOperator 
                                  expression
                                )                           
                              ;

unaryOperator
                              : UNARY_PLUS                  
                              | UNARY_MINUS                 
                              | NOT                         
                              | ABS                         
                              ;


rangeExpression
                              : ^( RANGE_DOTS
                                   from=expression
                                   to=expression
                                 )                          
                              ;




aggregateExpression

                              : ^( AGGREGATE
                                   ( expression             
                                   )+ 
                                 )                          
                              ;


linkExpression
                              : ^( linkExpressionType
                                   lhs=expression      
                                   relationshipSpec
                                   rhs=expression?
                                 )                          
                              ;
linkExpressionType
                              : LINK                        
                              | UNLINK                      
                              ;


navigateExpression
                              : ^( NAVIGATE
                                   expression
                                   relationshipSpec
                                                            
                                   ( whereClause           
                                   )?
                                 )                          
                                                                                          
                              ;

correlateExpression
                              : ^( CORRELATE
                                   lhs=expression
                                   rhs=expression
                                   relationshipSpec
                                 )                          
                              ;



orderByExpression
                              : ^( ( ORDERED_BY             
                                   | REVERSE_ORDERED_BY     
                                   ) 
                                   expression               
                                   ( sortOrder              
                                   )* 
                                 )                          
                              ;

sortOrder
                              : ^( SORT_ORDER_COMPONENT
                                   REVERSE?
                                   identifier               
                                 )
                              ;

createExpression
                              : ^( CREATE
                                   objectReference 
                                   ( createArgument
                                   )*
                                 )                          
                              ;

createArgument
                              : ^( CREATE_ARGUMENT
                                   attributeName
                                   expression )              
                              | ^( CURRENT_STATE
                                   stateName )               
                              ;

findExpression
                              : ^( findType
                                   expression               
                                   whereClause
                                 )                          
                              ;

whereClause
                              : ^( WHERE
                                   ( expression             
                                   )?
                                 )
                              ;

findType
                              : FIND                        
                              | FIND_ONE                    
                              | FIND_ONLY                   
                              ;


dotExpression
                              : ^( DOT
                                   expression
                                   identifier
                                 )                          
                              ;

terminatorServiceExpression
                              : ^( TERMINATOR_SCOPE
                                   expression
                                   identifier
                                 )                          
                              ;

callExpression
                              : ^( CALL
                                   expression               
                                   ( argument               
                                   )*                       
                                 )                          

                              ;

nameExpression
                              : ^( NAME
                                   identifier
                                 )                                
                              | ^( NAME
                                   domainReference
                                   identifier
                                 )                          
                              | ^( FIND_ATTRIBUTE
                                   identifier )             
                              | compoundTypeName            
                              ;


compoundTypeName
                              : instanceTypeRef             
                              | sequenceTypeRef             
                              | arrayTypeRef                
                              | setTypeRef                  
                              | bagTypeRef                  
                              ;


argument
                              : ^( ARGUMENT
                                   expression
                                 )                          
                              ;

sliceExpression
                              : ^( SLICE
                                   prefix=expression
                                   slice=expression
                                 )                          
                              ;

primeExpression
                              : ^( PRIME
	                                 expression
                                   identifier
                                   ( argument               
                                   )*                       
                                 )                          
                              ;

literalExpression
returns [StringBuilder text]
                              : IntegerLiteral              
                              {
                                  $text = new StringBuilder( $IntegerLiteral.text );
                              }
                              | RealLiteral                 
                              {
                                  $text = new StringBuilder( $RealLiteral.text );
                              }
                              | CharacterLiteral            
                              {
                                  $text = new StringBuilder( $CharacterLiteral.text );
                              }
                              | StringLiteral               
                              {
                                  $text = new StringBuilder( $StringLiteral.text );
                              }
                              | TimestampLiteral            
                              {
                                  $text = new StringBuilder( $TimestampLiteral.text );
                              }
                              | DurationLiteral             
                              {
                                  $text = new StringBuilder( $DurationLiteral.text );
                              }
                              | TRUE                        
                              {
                                  $text = new StringBuilder( $TRUE.text );
                              }
                              | FALSE                       
                              {
                                  $text = new StringBuilder( $FALSE.text );
                              }
                              | NULL                        
                              {
                                  $text = new StringBuilder( $NULL.text );
                              }
                              | FLUSH                       
                              {
                                  $text = new StringBuilder( $FLUSH.text );
                              }
                              | ENDL                        
                              {
                                  $text = new StringBuilder( $ENDL.text );
                              }
                              | THIS                        
                              {
                                  $text = new StringBuilder( $THIS.text );
                              }
                              | CONSOLE                     
                              {
                                  $text = new StringBuilder( $CONSOLE.text );
                              }
                              ; 
