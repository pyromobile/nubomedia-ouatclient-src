var tale={
	pages:['texto pagina 1','texto pagina 2','texto pagina 3','texto pagina 4','texto pagina 5','texto pagina 6','texto pagina 7'],
	currentPage:0,
	getText:function(){
		return this.pages[this.currentPage];
	},
	nextPage:function(){
		this.currentPage = ( this.currentPage >= this.pages.length-1 ) ? 0 : this.currentPage+1;
	},	
	prevPage:function(){
		this.currentPage = ( this.currentPage > 0 ) ? this.currentPage-1 : this.pages.length-1;
	}	
};