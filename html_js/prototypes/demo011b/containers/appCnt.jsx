'use-strict';

import React, {Component} from 'react';
import { Provider } from 'react-redux';
import { createStore, combineReducers } from 'redux';

//import reducer from '../reducers/reducer1';
import * as reducers from '../reducers';

//const store = createStore( reducer );
const reducer = combineReducers( reducers );
const store = createStore( reducer );

export default class AppCnt extends Component
{
  render()
  {
    return(
      <Provider store={store}>
        { this.props.children }
      </Provider>
    );
  }
}
