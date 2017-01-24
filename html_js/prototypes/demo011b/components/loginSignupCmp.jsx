'use-strict';

import React,{Component} from 'react';
import {Tab, Tabs} from 'react-toolbox';

import LoginCmp from './loginCmp';
import SignupCmp from './signupCmp';
import {Lang} from '../modules/languageCtrl';

export default class LoginSignupCmp extends Component
{
  constructor(props)
  {
    super(props);
  }

  render()
  {
    return (
      <div>
        <Tabs index={this.props.currentIndexTap} onChange={this.props.actions.changeAccessTap}>
          <Tab label={Lang.trans('loginsignup.login')}>
            <LoginCmp onLogin={this.props.actions.login}
                      onCancel={this.props.actions.cancel}
                      hasLoginError={this.props.error.hasLoginError}
                      errorDescription={this.props.error.errorDescription} />
          </Tab>
          <Tab label={Lang.trans('loginsignup.signup')}>
            <SignupCmp onSignup={this.props.actions.signup}
                       onCancel={this.props.actions.cancel}
                       hasSignupError={this.props.error.hasSignupError}
                       errorDescription={this.props.error.errorDescription}/>
          </Tab>
        </Tabs>
      </div>
    );
  }
}
