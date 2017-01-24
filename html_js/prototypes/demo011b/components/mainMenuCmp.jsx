'use-strict';

import React,{Component} from 'react';
import { Link } from 'react-router'

import {Lang} from '../modules/languageCtrl';

export default class MainMenuCmp extends Component
{
  render()
  {
    return(
      <div>
        <h1>Main Menu</h1>
        <ul role="nav">
          <li style={{display:this.props.isUserLogged?'none':'block'}}>
            <Link to="/login">
              {Lang.trans('mainmenu.login')}
            </Link>
          </li>
          <li style={{display:this.props.isUserLogged?'block':'none'}}>
            <Link to="/profile">
              {Lang.trans('mainmenu.profile')}
            </Link>
          </li>
          <li>
            <Link to="/settings">
              {Lang.trans('mainmenu.settings')}
            </Link>
          </li>
          <li>
            <Link to="/lobby/freemode">
              {Lang.trans('mainmenu.freeMode')}
            </Link>
          </li>
          <li>
            <Link to="/lobby/talemode">
              {Lang.trans('mainmenu.taleMode')}
            </Link>
          </li>
        </ul>
      </div>
    );
  }
}
