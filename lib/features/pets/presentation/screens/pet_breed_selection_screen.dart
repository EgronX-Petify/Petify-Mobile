import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';

class PetBreedSelectionScreen extends StatefulWidget {
  const PetBreedSelectionScreen({super.key});

  @override
  State<PetBreedSelectionScreen> createState() => _PetBreedSelectionScreenState();
}

class _PetBreedSelectionScreenState extends State<PetBreedSelectionScreen> {
  String? _selectedSpecies;
  String? _selectedBreed;
  final _searchController = TextEditingController();

  final Map<String, List<String>> _breedsBySpecies = {
    'Dog': [
      'Golden Retriever',
      'Labrador Retriever', 
      'German Shepherd',
      'Bulldog',
      'Poodle',
      'Beagle',
      'Rottweiler',
      'Yorkshire Terrier',
      'Dachshund',
      'Siberian Husky',
      'Shih Tzu',
      'Boston Terrier',
      'Pomeranian',
      'Border Collie',
      'Chihuahua',
    ],
    'Cat': [
      'Persian',
      'Maine Coon',
      'British Shorthair',
      'Ragdoll',
      'Bengal',
      'Abyssinian',
      'Birman',
      'Oriental Shorthair',
      'Manx',
      'Russian Blue',
      'Scottish Fold',
      'Siamese',
      'Sphynx',
      'American Shorthair',
      'Exotic Shorthair',
    ],
    'Bird': [
      'Budgerigar',
      'Cockatiel',
      'Canary',
      'Lovebird',
      'Conure',
      'Cockatoo',
      'Macaw',
      'African Grey',
      'Finch',
      'Parakeet',
    ],
    'Fish': [
      'Goldfish',
      'Betta',
      'Guppy',
      'Angelfish',
      'Tetra',
      'Molly',
      'Platy',
      'Swordtail',
      'Barb',
      'Danio',
    ],
  };

  final Map<String, String> _speciesImages = {
    'Dog': AppAssets.dogCategory,
    'Cat': AppAssets.catCategory,
    'Bird': AppAssets.birdCategory,
    'Fish': AppAssets.fishCategory,
  };

  List<String> get _filteredBreeds {
    if (_selectedSpecies == null) return [];
    
    final breeds = _breedsBySpecies[_selectedSpecies!] ?? [];
    final searchQuery = _searchController.text.toLowerCase();
    
    if (searchQuery.isEmpty) return breeds;
    
    return breeds.where((breed) => 
      breed.toLowerCase().contains(searchQuery)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.background),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Select Pet Breed',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Species Selection
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Choose Pet Species',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Species Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _speciesImages.keys.length,
                            itemBuilder: (context, index) {
                              final species = _speciesImages.keys.elementAt(index);
                              final isSelected = _selectedSpecies == species;
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSpecies = species;
                                    _selectedBreed = null;
                                    _searchController.clear();
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white : AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(25),
                                          child: Image.asset(
                                            _speciesImages[species]!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Icon(
                                              Icons.pets,
                                              color: isSelected ? AppColors.primary : Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        species,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Breed Selection
              if (_selectedSpecies != null) ...[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose ${_selectedSpecies!} Breed',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search breeds...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Breed List
                        Expanded(
                          child: _filteredBreeds.isEmpty
                              ? Center(
                                  child: Text(
                                    'No breeds found',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _filteredBreeds.length,
                                  itemBuilder: (context, index) {
                                    final breed = _filteredBreeds[index];
                                    final isSelected = _selectedBreed == breed;
                                    
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        onTap: () => setState(() => _selectedBreed = breed),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        tileColor: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[50],
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.primary : Colors.grey[300],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            Icons.pets,
                                            color: isSelected ? Colors.white : Colors.grey[600],
                                            size: 20,
                                          ),
                                        ),
                                        title: Text(
                                          breed,
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected ? AppColors.primary : Colors.black87,
                                          ),
                                        ),
                                        trailing: isSelected
                                            ? const Icon(
                                                Icons.check_circle,
                                                color: AppColors.primary,
                                              )
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Confirm Button
                Container(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedBreed != null ? _confirmSelection : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        _selectedBreed != null 
                            ? 'Select ${_selectedBreed!}'
                            : 'Choose a breed',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSelection() {
    if (_selectedSpecies != null && _selectedBreed != null) {
      Navigator.pop(context, {
        'species': _selectedSpecies!,
        'breed': _selectedBreed!,
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
