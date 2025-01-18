import UIKit

class OnboardingViewController: UIViewController {

    private var viewModel = OnboardingViewModel()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
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
        // Debugging print
        print("Cell frame: \(cell.frame)")
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = view.frame.size.width / 2 + scrollView.contentOffset.x
        
        // Loop through visible cells
        for cell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell),
                  let onboardingCell = cell as? OnboardingCell else { continue }
            
            let cellCenter = onboardingCell.center.x
            let distance = abs(center - cellCenter)
            
            // Define the maximum distance for scaling
            let maxDistance = collectionView.frame.width
            let scale = max(1 - distance / maxDistance, 0.5) // Minimum scale is 0.5
            
            onboardingCell.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / collectionView.frame.width)
        viewModel.updateCurrentPage(to: pageIndex)
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
            layout.itemSize = CGSize(width: collectionView.frame.height/2.04, height: collectionView.frame.height)
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
