'use-strict';

import React,{ Component, PropTypes } from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

import ProfileCmp from '../components/profileCmp';
import md5 from 'md5';
import UserCtrl from '../modules/userCtrl';
import * as LoginSignupActions from '../actions/loginSignupActions';

export class ProfileCnt extends Component
{
  constructor(props)
  {
    super(props);
    this.actions = {
      back:this.onBack.bind(this),
      saveChanges:this.onSaveChanges.bind(this)
    }
    this.userCode = md5( this.props.LoginSignUpReducer.userId );
  }

  render()
  {
    console.log( 'PROFILE_CNT - see state:', this.props.LoginSignUpReducer );
    return(
      <ProfileCmp actions={this.actions} userCode={this.userCode} nick={this.props.LoginSignUpReducer.nick} />
    );
  }

  onBack()
  {
    this.context.router.push('/');
  }

  onSaveChanges( user )
  {
    UserCtrl.getInstance().saveProfile( user )
          .then(function( user ){
            console.log('Save user profile ok!');
            this.props.loginSignupActions.changedProfile( user );
          }.bind(this))
          .catch(function(cause){
            console.log( 'onSaveChanges - error cause:', cause );
            //Any error in login shows the same message to avoid giving clues.
            //this.props.loginSignupActions.errorLogin( Lang.trans('loginsignup.login.error') );
          }.bind(this));
  }
}

ProfileCnt.contextTypes={
  router:React.PropTypes.object
}

//------------------------------------------------------------------------------
// Special functions to connect with redux
//------------------------------------------------------------------------------
function mapStateToProps( state, props )
{
  console.log( '****',state,'-', props );
  return state; //.LoginSignUpReducer;
}

function mapDispatchToProps( dispatch, props )
{
  return {
    loginSignupActions:bindActionCreators( LoginSignupActions, dispatch )
  };
}

export default connect( mapStateToProps, mapDispatchToProps )(ProfileCnt);
