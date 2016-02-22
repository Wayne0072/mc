/*----------------------------------------------------------------------------
 * File:  sys_user_co.c
 *
 * Description:
 * Interface call-outs allow the user to capture execution control of the
 * generated system running on a target.
 * Especially in the deeply embedded software/hardware development world,
 * it may be necessary to tightly interface the xtUML system to the
 * surrounding/containing system. MC-3020 provides callout routines
 * that enable the user to easily interface code generated by the model
 * compiler with other system code. These callout routines are empty when
 * generated by the model compiler. It is up to the user to define
 * additional functionality (if necessary) to be performed at these
 * callout points.
 *--------------------------------------------------------------------------*/

#include "masl_sys_types.h"
#include "masl_project_class.h"
#include "T_bridge.h"
#include "sys_user_co.h"

#ifdef SYS_USER_CO_PRINTF_ON
#include <stdio.h>
#define SYS_USER_CO_PRINTF( s ) printf( s );
#else
#define SYS_USER_CO_PRINTF( s )
#endif

/*
 * UserInitializationCallout
 *
 * This function is invoked at the immediate beginning of application
 * initialization. It is the very first function to be executed at system
 * startup.
 * User supplied implementation of this function should be restricted to
 * things like memory initialization, early hardware duties, etc.
 */
void
UserInitializationCalloutf( void )
{
/* Activate this invocation to initialize the example simple TIM.  */
  #if ESCHER_SYS_MAX_XTUML_TIMERS > 0
  TIM_init();
  #endif
  /* Insert implementation specific code here.  */
  SYS_USER_CO_PRINTF( "UserInitializationCallout\n" )
}

/*
 * UserPreOoaInitializationCallout
 *
 * This function is invoked immediately prior to executing any xtUML
 * initialization functions.
 */
void
UserPreOoaInitializationCalloutf( void )
{
  /* Insert implementation specific code here.  */
  SYS_USER_CO_PRINTF( "UserPreOoaInitializationCallout\n" )
}

/* 
 * serial_MASL_decode
 *
 * This function decodes a serial MASL string, replacing
 * special characters according to the following table:
 *
 * | Character | Encoding |
 * |:---------:|:--------:|
 * | %         | %25      |
 * | ,         | %2C      |
 * | \n        | %0A      |
 * | \r        | %0D      |
 *
 * Since, all replacements are fewer characters than the
 * original, it can be done in place with no need for 
 * reallocation.
 *
 * expects a well formed (null terminated) string as an
 * argument
 */
void
serial_MASL_decode( char * buf )
{
    if ( !buf ) return;

    char * b = buf;
    int buf_len = strlen(buf);

    while ( *b ) {

        // replace '%25' with '%'
        if ( *b == '%' && *(b+1) && *(b+1) == '2' && *(b+2) && *(b+2) == '5' ) {
            *b = '%';
            Escher_strcpy( b+1, b+3 );
        }
        // replace '%2C' with ','
        else if ( *b == '%' && *(b+1) && *(b+1) == '2' && *(b+2) && ( *(b+2) == 'C' || *(b+2) == 'c' ) ) {
            *b = ',';
            Escher_strcpy( b+1, b+3 );
        }
        // replace '%0A' with '\n'
        else if ( *b == '%' && *(b+1) && *(b+1) == '0' && *(b+2) && ( *(b+2) == 'A' || *(b+2) == 'a' ) ) {
            *b = '\n';
            Escher_strcpy( b+1, b+3 );
        }
        // replace '%0D' with '\r'
        else if ( *b == '%' && *(b+1) && *(b+1) == '0' && *(b+2) && ( *(b+2) == 'D' || *(b+2) == 'd' ) ) {
            *b = '\r';
            Escher_strcpy( b+1, b+3 );
        }
        else {
            // nothing
        }

        b++;

    }

}

/*
 * UserPostOoaInitializationCallout
 *
 * This function is invoked immediately after executing any xtUML
 * initialization functions.
 * When this callout function returns, the system dispatcher will allow the
 * xtUML application analysis state models to start consuming events.
 */
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
void
UserPostOoaInitializationCalloutf( int argc, char ** argv )
{
  char s[ 1024 ], element[ ESCHER_SYS_MAX_STRING_LEN ], value[ 8 ][ ESCHER_SYS_MAX_STRING_LEN ];
  char * p, * q;
  T_clear();
  while ( ( p = fgets( s, 1024, stdin ) ) != NULL ) {
    int i, j;
    i = 0;
    p[ strlen(p) - 1 ] = 0;
    if ( ( q = strsep( &p, "," ) ) != NULL ) Escher_strcpy( element, q );
    while ( ( q = strsep(&p, ",")) != NULL ) {
        Escher_strcpy( value[ i ], q );
        serial_MASL_decode( value[ i ] );
        i++;
    }
    masl_in_populate( element, value );
  }

  int validate = 0; int Validateonly = 0; int outputfile = 0; char * outputfilename = 0;
  {
    int c, index;
    opterr = 0;
    while ( ( c = getopt ( argc, argv, "vVo:" ) ) != -1 ) {
      switch ( c ) {
        case 'v':
          validate = 1; break;
        case 'V':
          Validateonly = 1; break;
        case 'o':
          outputfilename = optarg; break;
        case '?':
          if ('o' == optopt ) {
            fprintf( stderr, "Option -%c requires an argument.\n", optopt );
          } else if ( isprint (optopt) ) {
            fprintf( stderr, "Unknown option `-%c'.\n", optopt );
          } else {
            fprintf( stderr, "Unknown option character `\\x%x'.\n", optopt );
          }
        default:
          ; // CDS - abort ();
      }
    }
  }
  if ( validate || Validateonly ) {
    masl_gen_validate( "" );
  }
  if ( ! Validateonly ) {
    masl_gen_render( "project", "*" );
    if ( outputfilename ) {
      T_emit( outputfilename );
    } else {
      T_emit( "stdout" );
    }
  }
  exit(0);
}


/*
 * UserBackgroundProcessingCallout
 *
 * This function is invoked once during each loop execution of the system
 * dispather.
 * It is invoked at the 'top' of the system dispatcher loop, immediately
 * prior to dispatching any xtUML application analysis events.
 */
void
UserBackgroundProcessingCalloutf( void )
{
  /* Activate this invocation to periodically tick the example simple TIM.  */
  #if ESCHER_SYS_MAX_XTUML_TIMERS > 0
  TIM_tick();
  #endif
  /* Insert implementation specific code here.  */
}

/*
 * UserPreShutdownCallout
 *
 * This function is invoked at termination of the system dispatcher, but
 * prior to performing any xtUML application analysis shutdown sequencing.
 */
void
UserPreShutdownCalloutf( void )
{
  /* Insert implementation specific code here.  */
  SYS_USER_CO_PRINTF( "UserPreShutdownCallout\n" )
}

/*
 * UserPostShutdownCallout
 *
 * This function is invoked immediately before application exit.
 */
void
UserPostShutdownCalloutf( void )
{
  /* Insert implementation specific code here.  */
  SYS_USER_CO_PRINTF( "UserPostShutdownCallout\n" )
}

/*
 * UserEventCantHappenCallout
 *
 * This function is invoked any time that an event is received that
 * results in a "cant happen" transition.
 */
void
UserEventCantHappenCalloutf(
  const Escher_StateNumber_t current_state,
  const Escher_StateNumber_t next_state,
  const Escher_EventNumber_t event_number )
{
  /* Insert implementation specific code here.  */
  SYS_USER_CO_PRINTF( "UserEventCantHappenCallout\n" )
}

/*
 * UserEventNoInstanceCallout
 *
 * This function is invoked when we failed to validate the instance
 * to which an event was directed.  This can happen in normal operation
 * when the instance was deleted while the event was in flight (analysis
 * error).
 */
void
UserEventNoInstanceCalloutf(
  const Escher_EventNumber_t event_number )
{
  /* Insert implementation specific code here.  */
  SYS_USER_CO_PRINTF( "UserEventNoInstanceCallout\n" )
}

/*
 * UserEventFreeListEmptyCallout
 *
 * This function is invoked when an attempt is made to allocate an
 * event, but there are no more left.
 */
void
UserEventFreeListEmptyCalloutf( void )
{
  /* Insert implementation specific code here.  */
  SYS_USER_CO_PRINTF( "UserEventFreeListEmptyCallout\n" )
}

/*
 * UserEmptyHandleDetectedCallout
 *
 * This function is invoked when an attempt is made to use an instance
 * reference variable (handle) that is null (empty).
 */
void
UserEmptyHandleDetectedCalloutf( c_t * object_keyletters, c_t * s )
{
  /* Insert implementation specific code here.  */
  SYS_USER_CO_PRINTF( "UserEmptyHandleDetectedCallout\n" )
}

/*
 * UserObjectPoolEmptyCallout
 *
 * This function is invoked when an attempt is made to create an
 * instance of an object, but there are no instances available.
 */
void
UserObjectPoolEmptyCalloutf( const Escher_DomainNumber_t component_number, const Escher_ClassNumber_t class_number )
{
  /* Insert implementation specific code here.  */
  SYS_USER_CO_PRINTF( "UserObjectPoolEmptyCallout\n" )
}

/*
 * UserNodeListEmptyCallout
 *
 * This function is invoked when an attempt is made to allocate a
 * node, but there are no more left.
 */
void
UserNodeListEmptyCalloutf( void )
{
  /* Insert implementation specific code here.  */
  SYS_USER_CO_PRINTF( "UserNodeListEmptyCallout\n" )
}

/*
 * UserInterleavedBridgeOverflowCallout
 *
 * This function is invoked when an attempt is made to post too many
 * interleaved bridges.  The depth of this list is defined by
 * SYS_MAX_INTERLEAVED_BRIDGES (unless changed in the archetype).
 */
void
UserInterleavedBridgeOverflowCalloutf( void )
{
  /* Insert implementation specific code here.  */
  SYS_USER_CO_PRINTF( "UserInterleavedBridgeOverflowCallout\n" )
}

/*
 * UserSelfEventQueueEmptyCallout
 *
 * This function is invoked when the events to self queue is
 * interrogated and found to be empty.
 */
void
UserSelfEventQueueEmptyCalloutf( void )
{
  /* Insert implementation specific code here.  */
}

/*
 * UserNonSelfEventQueueEmptyCallout
 *
 * This function is invoked when the events to instance queue is
 * interrogated and found to be empty.
 */
void
UserNonSelfEventQueueEmptyCalloutf( void )
{
  /* Insert implementation specific code here.  */
}

/*
 * UserPersistenceErrorCallout
 *
 * This function is invoked when the events to instance queue is
 * interrogated and found to be empty.
 */
void
UserPersistenceErrorCalloutf( i_t error_code )
{
  /* Insert implementation specific code here.  */
  SYS_USER_CO_PRINTF( "UserPersistenceErrorCallout\n" )
}
