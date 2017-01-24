'use-strict';

import React,{Component} from 'react';
import Input from 'react-toolbox/lib/input';
import {Button} from 'react-toolbox/lib/button';

import {Lang} from '../modules/languageCtrl';

export default class LoginCmp extends Component
{
  constructor( props )
  {
    super(props);

    this.state = { user:'', password: '' };
  }

  render()
  {
    return(
      <div>
        <section>
          <Input type='text'
            label={Lang.trans('loginsignup.user')}
            icon='person'
            value={this.state.user}
            onChange={this.handleChange.bind(this, 'user')} />
          <Input type='password'
            label={Lang.trans('loginsignup.password')}
            icon='lock'
            name='password'
            value={this.state.password}
            onChange={this.handleChange.bind(this, 'password')} />
          <p style={{display:this.props.hasLoginError?'block':'none',color:'red'}}>
            {this.props.errorDescription}
          </p>
          <Button icon='play_arrow' floating onClick={this.onLogin.bind(this)} />
          <Button icon='clear' floating onClick={this.onCancel.bind(this)}/>
        </section>
      </div>
    );
  }

  handleChange(name, value)
  {
    //this.setState({...this.state, [name]: value});
    this.setState( Object.assign( {}, this.state, {[name]:value} ) );
  }

  onLogin()
  {
    this.props.onLogin( Object.assign( {}, this.state ) );
  }

  onCancel()
  {
    this.setState( { user:'', password: '' } );
    this.props.onCancel();
  }
}
