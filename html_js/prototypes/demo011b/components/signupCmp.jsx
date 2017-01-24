'use-strict';

import React,{Component} from 'react';
import Input from 'react-toolbox/lib/input';
import {Button} from 'react-toolbox/lib/button';

import {Lang} from '../modules/languageCtrl';

export default class SignupCmp extends Component
{
  constructor( props )
  {
    super(props);

    this.state = { user:'', password: '', passwordRepeated:'' };
  }

  render()
  {
    return(
      <div>
        <section>
          <Input type='text'
            label='User'
            icon='person'
            value={this.state.user}
            onChange={this.handleChange.bind(this, 'user')} />
          <Input type='password'
            label='Password'
            name='password'
            icon='lock'
            value={this.state.password}
            onChange={this.handleChange.bind(this, 'password')} />
          <Input type='password'
            label='Repeat password'
            name='passwordRepeated'
            icon='lock'
            value={this.state.passwordRepeated}
            onChange={this.handleChange.bind(this, 'passwordRepeated')} />
          <p style={{display:this.props.hasSignupError?'block':'none',color:'red'}}>
            {this.props.errorDescription}
          </p>
          <Button icon='play_arrow' floating onClick={this.onSignup.bind(this)} />
          <Button icon='clear' floating onClick={this.onCancel.bind(this)}/>
        </section>
      </div>
    );
  }

  handleChange( name, value )
  {
    //this.setState({...this.state, [name]: value});
    this.setState( Object.assign( {}, this.state, {[name]:value} ) );
  }

  onSignup()
  {
    this.props.onSignup( Object.assign( {}, this.state ) );
  }

  onCancel()
  {
    this.setState( { user:'', password: '', passwordRepeated:'' } );
    this.props.onCancel();
  }
}
