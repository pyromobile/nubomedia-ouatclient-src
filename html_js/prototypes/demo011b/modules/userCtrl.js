'use-strict';

import md5 from 'md5';

let UserCtrl = (function(){
  return {
    getInstance:function()
    {
      if( !mInstance )
        mInstance = _createInstance();

      return mInstance;
    }
  };
})();

export default UserCtrl;


//------------------------------------------------------------------------------
// Private section
//------------------------------------------------------------------------------
let mInstance = null;
let mLogged = false;

const tStep = {
  REGISTER:0,
  LOGIN:1,
  INTERNAL_TOKEN:2,
  PUBLIC_PROFILE:3,
  CREATE_USER_PUBLIC_PROFILE_STRUCTURE:4,
  CREATE_USER_FRIENDS_GROUP_STRUCTURE:5,
  WORKING:10,
  FAILED:11,
  FINISHED:12
};

function _createInstance()
{
  return {
    register:function( user )
    {
      var promise = new Promise( function( resolve, reject ){
        _runProcess( tStep.REGISTER, user, function( lastStep ){
          if( lastStep.current === tStep.FAILED )
          {
            console.log('UserCtrl::register - FAILED - error:',lastStep );
            reject( lastStep.error );
          }
          else if( lastStep.current === tStep.FINISHED )
            resolve( lastStep.data.user );
        });
      });
      return promise;
    },
    login:function( user )
    {
      var promise = new Promise( function( resolve, reject ){
        _runProcess( tStep.LOGIN, user, function( lastStep ){
          if( lastStep.current === tStep.FAILED )
            reject( lastStep.error );
          else if( lastStep.current === tStep.FINISHED )
            resolve( lastStep.data.user );
        });
      });
      return promise;
    },
    silenceLogin:function( accessToken )
    {
      var promise = new Promise( function( resolve, reject ){
        _silenceLogin( accessToken, function( lastStep ){
          if( lastStep.current === tStep.FAILED )
            reject( lastStep.error );
          else if( lastStep.current === tStep.FINISHED )
            resolve( lastStep.data.user );
        });
      });
      return promise;
    },
    saveProfile:function( user )
    {
      var promise = new Promise( function( resolve, reject ){
        _saveProfile( user, function( error, response ){
          if( error )
            reject( '** ERROR **' );
          else
            resolve( user );
        });
      });
      return promise;
    }
  };
}

function _runProcess( current, user, callback )
{
  let step = {
    current:current,
    data:{}
  };
  step.data.user = user;

  let intervalId = setInterval( function(){
    let exit = false;
    step = _updateProcess( step );
    if( step.current === tStep.FAILED )
    {
      exit = true;
    }
    else if( step.current === tStep.FINISHED )
    {
      exit = true;
    }

    if( exit )
    {
      clearInterval( intervalId );
      callback( step );
    }
  }, 100 );
}

function _updateProcess( step )
{
  switch( step.current )
  {
    case tStep.REGISTER:
      step.current = tStep.WORKING;
      _register( step.data.user, function( error, response ){
        if( error )
        {
          step.current = tStep.FAILED;
          if( response.status == 403 )
            step.error = 'USER_EXISTS_ALREADY';
        }
        else {
          step.current = tStep.LOGIN;
          step.lastCondition = tStep.CREATE_USER_PUBLIC_PROFILE_STRUCTURE;
        }
      });
      break;

    case tStep.LOGIN:
      step.current = tStep.WORKING;
      _login( step.data.user, function( error, response ){
        if( error )
        {
          step.current = tStep.FAILED;
          step.error = 'USER_NOT_FOUND';
        }
        else {
          mLogged = true;
          step.current = tStep.INTERNAL_TOKEN;
        }
      });
      break;

    case tStep.INTERNAL_TOKEN:
      step.current = tStep.WORKING;
      _internalToken( function( error, response ){
        if( error )
        {
          step.current = tStep.FAILED;
          step.error = 'USER_NOT_FOUND';
        }
        else {
          if( window.cordova === undefined )
          {
            //In browser.
            console.log('AccessTokenTwo:',response.accessToken);
          }
          else
          {
            //TODO: save in device.
          }

          step.current = ( step.lastCondition ) ?  step.lastCondition : tStep.PUBLIC_PROFILE;
        }
      });
      break;

    case tStep.PUBLIC_PROFILE:
      step.current = tStep.WORKING;
      _publicProfile( function( error, response ){
        if( error )
        {
          step.current = tStep.FAILED;
          step.error = 'USER_NOT_FOUND';
        }
        else
        {
          step.current = tStep.FINISHED;
          step.data.user.nick = response.nick;
          console.log('UserCtrl::_updateProcess - getPublicProfile:',response);
        }
      });
      break;

    case tStep.CREATE_USER_PUBLIC_PROFILE_STRUCTURE:
      step.current = tStep.WORKING;
      _createUserPublicProfile( function( error, response ){
        if( error )
        {
          step.current = tStep.FAILED;
          step.error = 'FAIL_USER_PUBLIC_PROFILE';
        }
        else {
          step.current = tStep.CREATE_USER_FRIENDS_GROUP_STRUCTURE;
        }
      });
      break;

    case tStep.CREATE_USER_FRIENDS_GROUP_STRUCTURE:
      step.current = tStep.WORKING;
      _createUserFriendsGroup( function( error, response ){
        if( error )
        {
          step.current = tStep.FAILED;
          step.error = 'FAIL_USER_FRIENDS_GROUP';
        }
        else {
          step.current = tStep.FINISHED;
          step.data.user.nick = 'gest';
        }
      });
      break;
  }

  return step;
}

function _register( user, callback )
{
  let options = {
    user:{
      fullName:user.user,
      authentication:{
        internalToken:{
          userId:user.user,
          accessToken:md5(user.password)
        }
      }
    }
  };
  console.log('UserCtrl::_register - Options:',options);
  Kuasars.Users.register( options, callback );
}

function _login( user, callback )
{
  let authentication = {
    accessToken:md5( user.password ),
    userId:user.user
  };

  Kuasars.Users.loginByInternalToken( authentication, callback );
}

function _internalToken( callback )
{
  Kuasars.Users.getInternalTokenTwo( null, callback );
}

function _publicProfile( callback )
{
  let entityType = {
    type:'users',
    entityId:'pub_'+Kuasars.Core.currentUser
  };

  Kuasars.Entities.get( entityType, callback );
}

function _createUserPublicProfile( callback )
{
  //Create user public profile.
  var publicProfile = {
    type:'users',
    entity:{
      id:'pub_' + Kuasars.Core.currentUser,
      nick:'guest',
      logged:mLogged
    }
  };

  //Add ACL to publicProfile.
  publicProfile.entity.acl = {read:{user:['ALL'],groups:[]},rw:{user:['NONE'],groups:[]},admin:{user:['NONE'],groups:[]}};

  Kuasars.Entities.save( publicProfile, callback );
}

function _createUserFriendsGroup( callback )
{
  //Create user friends group.
  var userFriendsGroup = {
    type:'friends',
    entity:{
      id:'grp_' + Kuasars.Core.currentUser,
      friends:[]
    }
  };

  //Add ACL to publicProfile.
  userFriendsGroup.entity.acl = {read:{user:['ALL'],groups:[]},rw:{user:['NONE'],groups:[]},admin:{user:['NONE'],groups:[]}};

  Kuasars.Entities.save( userFriendsGroup, callback );
}

function _silenceLogin( accessToken, callback )
{

}

function _saveProfile( user, callback )
{
  var publicProfile = {
    entityId: 'pub_' + Kuasars.Core.currentUser,
    type : 'users',
    entity : {
        nick : user.nick,
        logged:mLogged
    }
  };

  Kuasars.Entities.replace( publicProfile, callback );
}
