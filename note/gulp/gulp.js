var gulp = require('gulp');
var tinypng = require('gulp-tinypng-compress');
var tiny = require('gulp-tinypng-nokey');
gulp.task('tp', function() {
	directories.forEach(function(elem){
	gulp.src('[source-directory].{png,jpg,jpeg}')
		.pipe(tiny())
		.pipe(gulp.dest('[target-directory]'));
	});
})
	
