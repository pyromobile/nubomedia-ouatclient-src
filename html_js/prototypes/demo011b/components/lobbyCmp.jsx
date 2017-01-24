'use-strict';

import React,{ Component, PropTypes } from 'react';
//import { connect } from 'react-redux';
//import { bindActionCreators } from 'redux';

import Carousel, {ControllerMixin} from 'nuka-carousel';

export default class LobbyCmp extends Component
{
  constructor(props)
  {
    super(props);
  }

  render()
  {
    let index = 0;
    let books = this.props.books.map(function(book){
      let src = 'http://placehold.it/1000x400/ffffff/c0392b/&text='+book.title;
      return(
        <img key={++index} src={src} />
      );
    },this);

    return(
      <div>
        <Carousel style={{border:'1px solid black'}} afterSlide={this.currentTitleBook.bind(this)}>
          {books}
        </Carousel>
        <button onClick={this.select.bind(this)}>Seleccionar</button>
      </div>
    );
  }

  currentTitleBook( position )
  {
    this.props.actions.titleNavigation( position );
  }

  select()
  {
    this.props.actions.selectedBook();
  }
}
