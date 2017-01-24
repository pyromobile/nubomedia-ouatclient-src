'use-strict';

import React from 'react';
import {render} from 'react-dom';
import ToolboxApp from 'react-toolbox/lib/app';

import AppCnt from './containers/appCnt';
import AppRouterCnt from './containers/appRouterCnt';
import {Lang} from './modules/languageCtrl';

Lang.changeLanguage('en',function(){
  render(
    (
      <ToolboxApp>
        <AppCnt>
          <AppRouterCnt/>
        </AppCnt>
      </ToolboxApp>
    ),document.getElementById('app') );
}.bind(this));
