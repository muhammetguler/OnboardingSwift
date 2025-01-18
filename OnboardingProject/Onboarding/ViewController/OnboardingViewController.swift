import UIKit

class OnboardingViewController: UIViewController {

    private var viewModel = OnboardingViewModel()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = false
        collectionView.bounces = true // Enable bounce effect
        collectionView.isScrollEnabled = true // Enable scrolling
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .blue
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
    }

    private func setupView() {
        view.backgroundColor = .white

        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(collectionView)
        view.addSubview(pageControl)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(OnboardingCell.self, forCellWithReuseIdentifier: "OnboardingCell")

        // Constraints
        NSLayoutConstraint.activate([
            // Title Label at the top
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Description Label below the title
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Collection View below description label
            collectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5), // Adjust height as needed

            // Page Control below collection view
            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        pageControl.numberOfPages = viewModel.getSlideCount()
        
        updateLabels(for: 0)
    }

    private func bindViewModel() {
        viewModel.onPageChanged = { [weak self] currentPage in
            self?.updateLabels(for: currentPage)
        }
    }

    private func updateLabels(for page: Int) {
        let slide = viewModel.getSlide(at: page)
        titleLabel.text = slide.title
        descriptionLabel.text = slide.description
    }
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getSlideCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCell
        let slide = viewModel.getSlide(at: indexPath.item)
        cell.configure(with: slide.image)

        if viewModel.currentSlideIndex == indexPath.item {
            cell.transformToLarge()
        }
        
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let currentCell = collectionView.cellForItem(at: IndexPath(row: Int(viewModel.currentSlideIndex), section: 0))
        currentCell?.transformToStandard()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            
        guard scrollView == collectionView else {
            return
        }
        
        // Changing content offset to where the collection view stops scrolling
        targetContentOffset.pointee = scrollView.contentOffset
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let cellWidthIncludingSpacing = flowLayout.itemSize.width + flowLayout.minimumLineSpacing
        let offset = targetContentOffset.pointee
        let horizontalVelocity = velocity.x
        
        var selectedIndex = viewModel.currentSlideIndex
        
        switch horizontalVelocity {
        // On user swiping
        case _ where horizontalVelocity > 0 :
            selectedIndex = viewModel.currentSlideIndex + 1
        case _ where horizontalVelocity < 0:
            selectedIndex = viewModel.currentSlideIndex - 1
            
        // On user dragging
        case _ where horizontalVelocity == 0:
            let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
            let roundedIndex = round(index)
            
            selectedIndex = Int(roundedIndex)
        default:
            print("Incorrect velocity for collection view")
        }
        
        let safeIndex = max(0, min(selectedIndex, viewModel.getSlideCount() - 1))
        let selectedIndexPath = IndexPath(row: safeIndex, section: 0)
        
        flowLayout.collectionView!.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
        
        let previousSelectedIndex = IndexPath(row: Int(viewModel.currentSlideIndex), section: 0)
        let previousSelectedCell = collectionView.cellForItem(at: previousSelectedIndex)
        let nextSelectedCell = collectionView.cellForItem(at: selectedIndexPath)
        
        viewModel.updateCurrentPage(to: selectedIndexPath.row)
        
        previousSelectedCell?.transformToStandard()
        nextSelectedCell?.transformToLarge()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let centerOffset = collectionView.contentOffset.x + collectionView.frame.size.width / 2
        if let indexPath = collectionView.indexPathForItem(at: CGPoint(x: centerOffset, y: collectionView.frame.size.height / 2)) {
            print("Centered Cell Index: \(indexPath.item)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setOnboardPageData(indexPath.item)
    }

    func setOnboardPageData(_ currentIndex: Int, _ ischangeScrollPosition: Bool = true) {
        pageControl.currentPage = currentIndex
        collectionView.reloadData()

        guard ischangeScrollPosition else { return }
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: ischangeScrollPosition)
    }
}

extension OnboardingViewController {
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print("Collection View Frame: \(collectionView.frame)") // Collection View Frame: (0.0, 0.0, 0.0, 0.0)
        
        // Ensure the collection view has the correct frame
        collectionView.layoutIfNeeded()
        
        print("Collection View Frame: \(collectionView.frame)")

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: (collectionView.frame.height/1.25)/2.04, height: collectionView.frame.height/1.25)
            
            let peekingItemWidth = layout.itemSize.width / 10

            // Calculate horizontal insets to center the first and last cells
            let horizontalInset = (collectionView.frame.width - layout.itemSize.width) / 2
            collectionView.contentInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
            
            layout.minimumLineSpacing = horizontalInset - peekingItemWidth

            layout.invalidateLayout()
        }
    }
}

extension UICollectionViewCell {
    func transformToLarge() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
    }
    
    func transformToStandard() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
    }
    
}

/*
 
 Example: Why It’s Needed in Your Case
 Without layoutIfNeeded():

 The collection view's frame might still be CGRect.zero (default frame) when viewDidLayoutSubviews is called for the first time, which causes the UICollectionViewFlowLayout to calculate an incorrect itemSize.
 
 With layoutIfNeeded():

 The collection view forces its layout pass and resolves its constraints, updating its frame before you use it to calculate itemSize.
 
 */
