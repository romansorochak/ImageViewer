//
//  ImageViewerViewController.swift
//  ImageViewerControl
//
//  Created by RomanSorochak on 08.07.15.
//  Copyright (c) 2015 SorikProduction. All rights reserved.
//

import UIKit

class ImageViewerViewController : UIViewController {
    
    // MARK - outlets
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    
    var pageImages: [UIImage] = []
    var currentImage: Int = 0
    private var pageImageViews: [UIImageView?] = []
    private var pageScrollViews: [UIScrollView?] = []
    
    
    // MARK - ViewController life cycle
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setup()
        
        loadVisiblePages()
    }
}


// MARK - setup
extension ImageViewerViewController {
    
    private func setup() {
        
        setupNavigationBar()
        
        setupPageControl()
        
        setupPages()
        
        setupScrollView()
        
        setupGestures()
    }
    
    private func setupNavigationBar() {
        
    }
    
    private func setupPageControl() {
        
        let pageCount = pageImages.count
        
        pageControl.currentPage = currentImage
        pageControl.numberOfPages = pageCount
    }
    
    private func setupPages() {
        
        let pageCount = pageImages.count
        for _ in 0..<pageCount {
            pageImageViews.append(nil)
            pageScrollViews.append(nil)
        }
    }
    
    private func setupScrollView() {
        
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSize(
            width: pagesScrollViewSize.width * CGFloat(pageImages.count),
            height: pagesScrollViewSize.height
        )
    }
    
    private func setupGestures() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: Selector("imageViewDidTap:")
        )
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: Selector("imageViewDoubleDidTap:")
        )
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
}


// MARK - lazy loading of images
extension ImageViewerViewController {
    
    func loadVisiblePages() {
        
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < pageImages.count; ++index {
            purgePage(index)
        }
    }
    
    func loadPage(page: Int) {
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Load an individual page, first checking if you've already loaded it
        if let pageView = pageImageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            frame = CGRectInset(frame, 10.0, 0.0)
            
            // new scroll view
            let pageScrollView = UIScrollView(frame: frame)
            pageScrollView.delegate = self
            pageScrollView.bouncesZoom = true
            pageScrollView.clipsToBounds = true
            // Set up the minimum & maximum zoom scales
            let scrollViewFrame = scrollView.frame
            let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
            let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
            let minScale = min(scaleWidth, scaleHeight)
            
            pageScrollView.minimumZoomScale = 0.5//minScale
            pageScrollView.maximumZoomScale = 1.0
            pageScrollView.zoomScale = 1.0
            
            pageScrollView.contentSize = pageImages[page].size
            
            scrollView.addSubview(pageScrollView)
            
            // new image
            let newPageImageView = UIImageView(image: pageImages[page])
            newPageImageView.contentMode = .ScaleAspectFit
            newPageImageView.frame = pageScrollView.bounds
            
            pageScrollView.addSubview(newPageImageView)
            
            pageImageViews[page] = newPageImageView
            pageScrollViews[page] = pageScrollView
            
            centerScrollViewContentsForScrollView(pageScrollView)
        }
    }
    
    func purgePage(page: Int) {
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageScrollView = pageImageViews[page] {
            if let pageImageView = pageScrollViews[page] {
                
                pageImageView.removeFromSuperview()
                pageImageViews[page] = nil
                
                pageScrollView.removeFromSuperview()
                pageScrollViews[page] = nil
            }
        }
    }
}


// MARK - centering imageview after zoom in/out
extension ImageViewerViewController {
    
    private func zoomInWithGesture(gesture: UITapGestureRecognizer) {
        
        if let imageView = pageImageViews[currentImage] {
            
            // 1
            let pointInView = gesture.locationInView(imageView)
            
            // 2
            var newZoomScale = scrollView.zoomScale * 1.5
            newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
            
            // 3
            let scrollViewSize = scrollView.bounds.size
            let w = scrollViewSize.width / newZoomScale
            let h = scrollViewSize.height / newZoomScale
            let x = pointInView.x - (w / 2.0)
            let y = pointInView.y - (h / 2.0)
            
            let rectToZoomTo = CGRectMake(x, y, w, h);
            
            // 4
            scrollView.zoomToRect(rectToZoomTo, animated: true)
        }
    }
    
    private func centerScrollViewContentsForScrollView(scrollView: UIScrollView) {
        
        if let imageView = pageImageViews[currentImage] {
            
            let boundsSize = scrollView.bounds.size
            var contentsFrame = imageView.frame
            
            if contentsFrame.size.width < boundsSize.width {
                contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
            } else {
                contentsFrame.origin.x = 0.0
            }
            
            if contentsFrame.size.height < boundsSize.height {
                contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
            } else {
                contentsFrame.origin.y = 0.0
            }
            
            imageView.frame = contentsFrame
        }
    }
}


// MARK - gesture handlers
extension ImageViewerViewController {
    
    func imageViewDidTap(gesture: UITapGestureRecognizer) {
        
        if self.navigationController?.navigationBar.alpha == 1 {
            
            hideNavigationBar()
        } else {
            
            showNavigationBar()
        }
    }
    
    func imageViewDoubleDidTap(gesture: UITapGestureRecognizer) {
        
        zoomInWithGesture(gesture)
    }
}


// MARK - animations
extension ImageViewerViewController {
    
    private func showNavigationBar() {
        
        let navBar = self.navigationController?.navigationBar
        animateAlpha(1, forView: navBar!)
    }
    
    private func hideNavigationBar() {
        
        let navBar = self.navigationController?.navigationBar
        animateAlpha(0, forView: navBar!)
    }
    
    private func animateAlpha(alpha: CGFloat, forView view: UIView) {
        
        UIView.animateWithDuration(0.2,
            animations: { () -> Void in
                
                view.alpha = alpha
                
            }) { (finished) -> Void in
                
        }
    }
}


// MARK - UIScrollViewDelegate
extension ImageViewerViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return pageImageViews[currentImage]
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContentsForScrollView(self.scrollView)
    }
}
