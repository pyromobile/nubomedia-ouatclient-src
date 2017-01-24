'use-strict';

import React,{Component} from 'react';
import { Router, Route, hashHistory } from 'react-router';

import MainMenuCnt from './mainMenuCnt';
import LoginSignupCnt from './loginSignupCnt';
import ProfileCnt from './profileCnt';
import SettingsMenuCmp from '../components/settingsMenuCmp';
import LobbyCnt from './lobbyCnt';
import FreeModeCnt from './freeModeCnt';
import TaleModeCnt from './taleModeCnt';

export default class AppRouterCnt extends Component
{
  render()
  {
    return(
      <Router history={hashHistory}>
        <Route path='/' component={MainMenuCnt}></Route>
        <Route path='/login' component={LoginSignupCnt}></Route>
        <Route path='/profile' component={ProfileCnt}></Route>
        <Route path='/settings' component={SettingsMenuCmp}></Route>
        <Route path='/lobby/:mode' component={LobbyCnt}></Route>
        <Route path='/freemode' component={FreeModeCnt}></Route>
        <Route path='/talemode/:bookId' component={TaleModeCnt}></Route>
      </Router>
    );
  }
}
