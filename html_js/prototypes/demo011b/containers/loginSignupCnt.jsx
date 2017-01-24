'use-strict';

import React,{ Component, PropTypes } from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

//import Kuasars from '../modules/kuasars.min';
//var Kuasars = require('../modules/kuasars.min.js');
import LoginSignupCmp from '../components/loginSignupCmp';
import * as LoginSignupActions from '../actions/loginSignupActions';
import md5 from 'md5';
import {Lang} from '../modules/languageCtrl';
import UserCtrl from '../modules/userCtrl';

export class LoginSignupCnt extends Component
{
  constructor( props )
  {
    super(props);

    this.actions = {
      changeAccessTap:this.onChangeAccessTap.bind( this ),
      login:this.onLogin.bind( this ),
      signup:this.onSignup.bind( this ),
      cancel:this.onCancel.bind( this )
    };

    //Init kuasars library.
    Kuasars.Core.init( 'PRO', 'v1', '560ab6e3e4b0b185810131aa' );
  }

  render()
  {
    return(
      <LoginSignupCmp
        actions={this.actions}
        currentIndexTap={this.props.LoginSignUpReducer.currentIndexTap}
        error={this.props.LoginSignUpReducer.error} />
    );
  }

  onChangeAccessTap( indexTap )
  {
    this.props.loginSignupActions.changeAccessTap( indexTap );
  }

  onLogin( user, needCreateStructures=false )
  {
    UserCtrl.getInstance().login( user )
      .then(function( user ){
        this.loginLastStep( user );
      }.bind(this))
      .catch(function(cause){
        console.log( 'onLogin - error cause:', cause );
        //Any error in login shows the same message to avoid giving clues.
        this.props.loginSignupActions.errorLogin( Lang.trans('loginsignup.login.error') );
      }.bind(this));
  }

  onSignup( user )
  {
    if( user.password === user.passwordRepeated )
    {
      UserCtrl.getInstance().register( user )
        .then(function( user ){
          this.loginLastStep( user );
        }.bind(this))
        .catch(function(cause){
          console.log( 'onSignup - error cause:', cause );
          this.props.loginSignupActions.errorSignup(Lang.trans('loginsignup.signup.userExists.error'));
        }.bind(this));
    }
    else
    {
      this.props.loginSignupActions.errorSignup( Lang.trans('loginsignup.signup.password.error') );
    }
  }

  onCancel()
  {
    this.props.loginSignupActions.cancelSignupLogin();
    this.context.router.push('/');
  }

  loginLastStep( user )
  {
    this.context.router.push('/');
    this.props.loginSignupActions.logged( user.user, user.nick );
  }
}

LoginSignupCnt.contextTypes={
  router:React.PropTypes.object
}

//------------------------------------------------------------------------------
// Special functions to connect with redux
//------------------------------------------------------------------------------
function mapStateToProps( state, props )
{
  return state; //.LoginSignUpReducer;
}

function mapDispatchToProps( dispatch, props )
{
  return {
    loginSignupActions:bindActionCreators( LoginSignupActions, dispatch )
  };
}

export default connect( mapStateToProps, mapDispatchToProps )(LoginSignupCnt);
